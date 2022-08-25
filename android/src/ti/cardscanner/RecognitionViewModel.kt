package ti.cardscanner

import android.graphics.Bitmap
import androidx.camera.core.ImageProxy
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import org.appcelerator.kroll.common.Log
import android.graphics.Rect

class RecognitionViewModel(private val mobileService: MobileService) : ViewModel() {

    private val gmsTextRecognition = GmsTextRecognition()

    private var startCycleComputingFpsTimestamp = 0L
    private var framesCounter = 0

    val realtimeResultsLiveData = MutableLiveData<List<RecognizedLine>>()
    val captureResultsLiveData = MutableLiveData<List<RecognizedLine>>()

    val fpsLiveData = MutableLiveData<Int>()

    //@androidx.camera.core.ExperimentalGetImage
    fun onFrameReceived(imageProxy: ImageProxy) {

      //  recomputeFps()

        val frame = imageProxy.image

        if (frame == null) {
            imageProxy.close()
            return
        }
        else {
        
        val rotationDegrees = imageProxy.imageInfo.rotationDegrees

        val imageHeight = frame.height
        val imageWidth = frame.width

        val actualAspectRatio = imageWidth / imageHeight

        val convertImageToBitmap = ImageUtils.convertYuv420888ImageToBitmap(frame)
        val cropRect = Rect(0, 0, imageWidth, imageHeight)
        
        var currentCropPercentages = Pair(50, 4)
        if (actualAspectRatio > 3) {
            val originalHeightCropPercentage = currentCropPercentages.first
            val originalWidthCropPercentage = currentCropPercentages.second
            currentCropPercentages =  Pair(originalHeightCropPercentage / 2, originalWidthCropPercentage)
        }

        // If the image is rotated by 90 (or 270) degrees, swap height and width when calculating
        // the crop.
        val cropPercentages = currentCropPercentages
        val heightCropPercent = cropPercentages.first
        val widthCropPercent = cropPercentages.second
        val (widthCrop, heightCrop) = when (rotationDegrees) {
            90, 270 -> Pair(heightCropPercent / 100f, widthCropPercent / 100f)
            else -> Pair(widthCropPercent / 100f, heightCropPercent / 100f)
        }

        cropRect.inset(
            (imageWidth * widthCrop / 2).toInt(),
            (imageHeight * heightCrop / 2).toInt()
        )
        
        val croppedBitmap = ImageUtils.rotateAndCrop(convertImageToBitmap, rotationDegrees, cropRect)
                gmsTextRecognition
                    .processFrame(croppedBitmap, rotationDegrees)
                    .addOnCompleteListener { imageProxy.close() }
                    .addOnSuccessListener {
                        
                   		//Log.w("RTRT", "data: "+it)

                        //Timber.tag("RTRT").d("On-device realtime result:$it")
                        realtimeResultsLiveData.postValue(it)
                    }
                    .addOnFailureListener { 
                        //Timber.e(it) 
                    }


        }
   }

 
    private fun recomputeFps() {
        val currentTimestamp = System.currentTimeMillis()
        if (startCycleComputingFpsTimestamp == 0L) {
            startCycleComputingFpsTimestamp = currentTimestamp
            return
        }

        val diff = currentTimestamp - startCycleComputingFpsTimestamp
        if (diff < 1000) {
            framesCounter++
        } else {
            fpsLiveData.postValue(framesCounter)
            framesCounter = 0
            startCycleComputingFpsTimestamp = currentTimestamp
        }
    }
}