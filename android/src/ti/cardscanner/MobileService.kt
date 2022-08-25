package ti.cardscanner

import android.content.Context
import com.google.android.gms.common.GoogleApiAvailability

enum class MobileService {
    GMS
}

internal typealias GMSConnectionResult = com.google.android.gms.common.ConnectionResult

fun Context.getMobileService(): MobileService =
    when {
        GoogleApiAvailability.getInstance()
            .isGooglePlayServicesAvailable(this) == GMSConnectionResult.SUCCESS -> MobileService.GMS
        else -> error("Unsupported mobile service type")
    }

