package ti.cardscanner

import permissions.dispatcher.NeedsPermission
import permissions.dispatcher.RuntimePermissions
import android.Manifest

import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.Surface
import android.view.View
import android.view.ViewGroup
import androidx.activity.OnBackPressedCallback
import androidx.camera.core.AspectRatio
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ExperimentalUseCaseGroup
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.Preview
import androidx.camera.core.TorchState
import androidx.camera.core.UseCaseGroup
import androidx.camera.lifecycle.ExperimentalUseCaseGroupLifecycle
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.LiveData
import ti.cardscanner.R
import java.io.File
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.concurrent.Executors
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.Array
import kotlin.Int
import kotlin.IntArray
import kotlin.String
import permissions.dispatcher.PermissionUtils
import org.appcelerator.kroll.common.Log
import org.appcelerator.kroll.KrollModule
import org.appcelerator.kroll.annotations.Kroll
import org.appcelerator.kroll.KrollFunction
import org.appcelerator.kroll.KrollDict
import org.appcelerator.kroll.KrollObject
import java.util.Timer
import kotlin.concurrent.schedule

class RecognitionFragment : Fragment() {
private val REQUEST_STARTCARDIORECOGNITION: Int = 0

private val PERMISSION_STARTCARDIORECOGNITION: Array<String> = arrayOf("android.permission.CAMERA")

private val REQUEST_STARTMLKITRECOGNITION: Int = 1

private val PERMISSION_STARTMLKITRECOGNITION: Array<String> = arrayOf("android.permission.CAMERA")

private var torchEnabled:Boolean = false


    private val viewModel: RecognitionViewModel by viewModels {
        RecognitionViewModelFactory(requireContext().getMobileService())
    }
    private val cameraExecutor = Executors.newSingleThreadExecutor()
    private lateinit var camera: Camera
    private var flashStateLiveData: LiveData<Int>? = null


fun switchTorch() {
    if (torchEnabled == true){
        torchEnabled = false
    }
    else {
        torchEnabled = true
    }
   camera.cameraControl.enableTorch(torchEnabled)
}



fun isNumeric(toCheck: String): Boolean {
    val regex = "-?[0-9]+(\\.[0-9]+)?".toRegex()
    return toCheck.matches(regex)
}


fun startMlKitRecognitionWithPermissionCheck() {
  if (PermissionUtils.hasSelfPermissions(this.requireActivity(),
      *PERMISSION_STARTMLKITRECOGNITION)) {
    startMlKitRecognition()
  } else {
    this.requestPermissions(PERMISSION_STARTMLKITRECOGNITION, REQUEST_STARTMLKITRECOGNITION)
  }
}


fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
  when (requestCode) {
    REQUEST_STARTMLKITRECOGNITION ->
     {
      if (PermissionUtils.verifyPermissions(*grantResults)) {
        startMlKitRecognition()
      }
    }
  }
}




    private val framesAnalyzer: ImageAnalysis.Analyzer by lazy {
        ImageAnalysis.Analyzer(viewModel::onFrameReceived)
    }

    private var _binding: FragmentRecognitionBinding? = null
    private val binding
        get() = requireNotNull(_binding)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requireActivity()
            .onBackPressedDispatcher
            .addCallback(this, object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    ActivityScan.getInstance().finish()
                }
            })

        
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentRecognitionBinding.inflate(inflater, container, false)
        return binding.root
    }

    //@ExperimentalUseCaseGroup
    //@ExperimentalUseCaseGroupLifecycle
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        var success:Boolean = false

        var finalowner:String=""
        var finalcardnumber: String= ""
        var finalmonth: String= ""
        var finalyear: String= ""
        var finalexpiry: String= ""


        var tempmonth: Int= 0
        var tempyear: Int= 0
        var tempcardnumber: String= ""


        viewModel.realtimeResultsLiveData.observe(viewLifecycleOwner) { lines ->
        val textLines = lines.map { it.text }
        val mylines = textLines
        
        if (success == false) {
            
            if (finalyear == "" || finalmonth == ""){
                val (month, year) = extractExpiration(mylines)
                if (month != null && year != null){
    
                    if (finalmonth == "" && isNumeric(month)){
                        if (month.toInt()<=12){
                            if (tempmonth == 0){
                                tempmonth = month.toInt()
                            }
                            else {
                                if (tempmonth == month.toInt()){
                                    finalmonth = month
                                }            
                            }   
                        }
                    }
    
                    if (finalyear == "" && isNumeric(year)){
                        if (tempyear == 0){
                                tempyear = year.toInt()
                        }
                        else {
                             if (tempyear == year.toInt()){
                                 finalyear = year
                             }            
                        }
                    }
                }
            }
            else {
                    if (finalyear != "" && finalmonth != ""){
                        finalexpiry = finalmonth+"/"+finalyear
                       binding.succeedResultsTextView.text = String.format("%s\n%s\n%s", finalcardnumber, finalexpiry, finalowner)
                   		//Log.w("MONTH/YEAR", "set ")
                    }
            }
        
         if (finalowner == "") {
            val owner = extractOwner(mylines)
            if (owner != null && owner.length >= 4 && owner.contains(" ")) {
                finalowner = owner
                binding.succeedResultsTextView.text = String.format("%s\n%s\n%s", finalcardnumber, finalexpiry, finalowner)
            } 
        }
           
        if (finalcardnumber == "") {
               // val cardnumber = extractNumber(mylines)
                
           val cardnumber = textLines.firstOrNull { line ->
                val subNumbers = line.split(" ")
                subNumbers.isNotEmpty() && subNumbers.flatMap { it.asIterable() }.all { it.isDigit() }
            }

                
                if (cardnumber != null && cardnumber.replace(" ", "").length >= 16) {
                     //finalcardnumber = cardnumber
                     finalcardnumber = cardnumber
                     binding.succeedResultsTextView.text = String.format("%s\n%s\n%s", finalcardnumber, finalexpiry, finalowner)
                    /*
                    if (tempcardnumber == ""){
                        tempcardnumber = cardnumber.replace(" ", "")
                    }
                    else {
                        if (tempcardnumber == cardnumber.replace(" ", "")){
                            finalcardnumber = cardnumber
                            binding.succeedResultsTextView.text = String.format("%s\n%s\n%s", finalcardnumber, finalmonth+"/"+finalyear, finalowner)
                            //val previousText = binding.succeedResultsTextView.text
                            //binding.succeedResultsTextView.text = String.format("%s\n%s", previousText, cardnumber)
                        }
                    }
                    */
                }
        }

      if (finalexpiry != "" && finalowner != "" && finalcardnumber != ""){
                        success = true
                         binding.succeedResultsTextView.text = String.format("%s\n%s\n%s", finalcardnumber, finalexpiry, finalowner)
                        
                   	//	Log.e("success", " +++++++++++++++++++ ")

                        
                        var dict: KrollDict = KrollDict()
                        dict.put("owner", finalowner)
                        dict.put("number", finalcardnumber.replace(" ", ""))
                        dict.put("expiry", finalexpiry)
                       
                         TiCardscannerModule.getInstance().fireCallback(dict)
                                                 
                        Timer("Closing", false).schedule(2000) { 
                        	ActivityScan.getInstance().finish()
                        }
         }
    }


/*
            binding.resultsTextView.text = textLines.joinToString("\n")

            val number = textLines.firstOrNull { line ->
                val subNumbers = line.split(" ")
                subNumbers.isNotEmpty() && subNumbers.flatMap { it.asIterable() }.all { it.isDigit() }
            }

            if (number != null && number.replace(" ", "").length >= 16) {
                val previousText = binding.succeedResultsTextView.text
                binding.succeedResultsTextView.text = String.format("%s\n%s", previousText, number)

                binding.numberTextView.text = number
                binding.numberTextView.setTextColor(ContextCompat.getColor(requireContext(), R.color.success))
            } else {
                if (number != null && number.replace(" ", "").length >= 5 && number.contains("/")) {
                }
                                
                binding.numberTextView.text = getString(R.string.recognition_failed)
                binding.numberTextView.setTextColor(ContextCompat.getColor(requireContext(), R.color.error))
            }
*/
        }
    
        viewModel.captureResultsLiveData.observe(viewLifecycleOwner) { lines ->
            if (lines == null) return@observe

            val results = lines.joinToString("\n") { it.text }
           // val dialog = ResultDialogFragment.create(results)
           // dialog.show(childFragmentManager, ResultDialogFragment::class.simpleName)
        }
       
        startMlKitRecognitionWithPermissionCheck()
    }


    private fun extractOwner(lines: List<String>): String? {
        return lines
            .filter { it.contains(" ") }
            .filter { line -> line.asIterable().none { char -> char.isDigit() } }
            .maxByOrNull { it.length }
    }

    private fun extractNumber(lines: List<String>): String? {
        return lines.firstOrNull { line ->
            val subNumbers = line.split(" ")
            subNumbers.isNotEmpty() && subNumbers.flatMap { it.asIterable() }.all { it.isDigit() }
        }
    }

    private fun extractExpiration(lines: List<String>): Pair<String?, String?> {
        val expirationLine = extractExpirationLine(lines)

        val month = expirationLine?.substring(startIndex = 0, endIndex = 2)
        val year = expirationLine?.substring(startIndex = 3)
        return Pair(month, year)
    }

    private fun extractExpirationLine(lines: List<String>) =
        lines.flatMap { it.split(" ") }
            .firstOrNull { (it.length == 5 || it.length == 7) && it[2] == '/' }



    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    @NeedsPermission(Manifest.permission.CAMERA)
    internal fun startMlKitRecognition() {
        startCamera()
    }



//    @ExperimentalUseCaseGroup
//    @ExperimentalUseCaseGroupLifecycle
    fun startCamera() {
        ProcessCameraProvider.getInstance(requireContext())
            .apply {
                addListener(
                    { bindCameraUseCases(get()) },
                    ContextCompat.getMainExecutor(requireContext())
                )
            }
    }

  //  @ExperimentalUseCaseGroup
  //  @ExperimentalUseCaseGroupLifecycle
    private fun bindCameraUseCases(cameraProvider: ProcessCameraProvider) {
        val screenAspectRatio = aspectRatio(binding.cameraPreview.width, binding.cameraPreview.height)

        val preview = Preview.Builder()
            .setTargetRotation(Surface.ROTATION_0)
            .setTargetAspectRatio(screenAspectRatio)
            .build()
            .also { it.setSurfaceProvider(binding.cameraPreview.surfaceProvider) }

        val imageAnalyzer = ImageAnalysis.Builder()
            .setTargetRotation(Surface.ROTATION_0)
            .setTargetAspectRatio(screenAspectRatio)
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .build()
            .also { it.setAnalyzer(cameraExecutor, framesAnalyzer) }

//        imageCapture = ImageCapture.Builder()
 //           .setTargetRotation(Surface.ROTATION_0)
//            .setTargetAspectRatio(screenAspectRatio)
//            .setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY)
//            .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
//            .build()

        val useCaseGroup = UseCaseGroup.Builder().run {
            addUseCase(preview)
            addUseCase(imageAnalyzer)
            binding.cameraPreview.viewPort?.let { setViewPort(it) }
            build()
        }

        try {
            cameraProvider.unbindAll()
            camera = cameraProvider.bindToLifecycle(
                viewLifecycleOwner,
                CameraSelector.DEFAULT_BACK_CAMERA,
                useCaseGroup
            )
        } catch (t: Throwable) {
            //Timber.e(t, "Camera use cases binding failed")
        }
    }

    private fun aspectRatio(width: Int, height: Int): Int {
        val previewRatio = max(width, height).toDouble() / min(width, height)
        if (abs(previewRatio - RATIO_4_3_VALUE) <= abs(previewRatio - RATIO_16_9_VALUE)) {
            return AspectRatio.RATIO_4_3
        }
        return AspectRatio.RATIO_16_9
    }


    companion object {
        private const val RATIO_4_3_VALUE = 4.0 / 3.0
        private const val RATIO_16_9_VALUE = 16.0 / 9.0
    }
}