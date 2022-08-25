package ti.cardscanner

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider

class RecognitionViewModelFactory(private val mobileService: MobileService) : ViewModelProvider.Factory {
    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        return RecognitionViewModel(mobileService) as T
    }
}