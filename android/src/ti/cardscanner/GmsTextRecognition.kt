package ti.cardscanner

import android.graphics.Bitmap
import android.media.Image
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.Text
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.common.model.LocalModel
import com.google.mlkit.vision.text.latin.TextRecognizerOptions;
import com.google.mlkit.vision.text.TextRecognizerOptionsInterface

class GmsTextRecognition {

    //private val analyzer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

    private val analyzer: TextRecognizer = TextRecognition.getClient(TextRecognizerOptions.Builder().build())


    fun processFrame(frame: Image, rotationDegrees: Int): Task<List<RecognizedLine>> {
        val inputImage = InputImage.fromMediaImage(frame, rotationDegrees)

        return analyzer
            .process(inputImage)
            .continueWith { task->
                task.result
                    .textBlocks
                    .flatMap { block -> block.lines }
                    .map { line -> line.toRecognizedLine() }
            }
    }

    fun processFrame(bitmap: Bitmap, rotationDegrees: Int): Task<List<RecognizedLine>> {
        val inputImage = InputImage.fromBitmap(bitmap, rotationDegrees)

        return analyzer
            .process(inputImage)
            .continueWith { task ->
                task.result
                    .textBlocks
                    .flatMap { block -> block.lines }
                    .map { line -> line.toRecognizedLine() }
            }
    }

    private fun Text.Line.toRecognizedLine(): RecognizedLine =
        RecognizedLine(text)
}