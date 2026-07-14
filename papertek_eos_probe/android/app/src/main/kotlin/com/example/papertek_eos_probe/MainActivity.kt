package com.example.papertek_eos_probe

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "papertek_eos_probe/network"
    private lateinit var connectivityManager: ConnectivityManager
    private var boundWifi: Network? = null
    private var callbackRegistered = false

    private val wifiCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            bindNetwork(network)
        }

        override fun onLost(network: Network) {
            if (boundWifi == network) {
                boundWifi = null
                if (!bindAvailableWifi()) {
                    bindProcess(null)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        connectivityManager =
            getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        // Bind before Dart creates its first UDP socket. Android can otherwise
        // select cellular as the process default when Wi-Fi has no internet.
        bindAvailableWifi()
        registerWifiCallback()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "bindWifi" -> {
                        if (bindAvailableWifi()) {
                            result.success(bindingDetails())
                        } else {
                            result.error(
                                "NO_WIFI",
                                "No active Wi-Fi network is available for Eos UDP.",
                                null,
                            )
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        if (callbackRegistered) {
            connectivityManager.unregisterNetworkCallback(wifiCallback)
            callbackRegistered = false
        }
        bindProcess(null)
        boundWifi = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun registerWifiCallback() {
        if (callbackRegistered) return
        val request = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            .build()
        connectivityManager.registerNetworkCallback(request, wifiCallback)
        callbackRegistered = true
    }

    @Synchronized
    private fun bindAvailableWifi(): Boolean {
        val current = boundWifi
        if (current != null && isWifi(current)) return true
        val wifi = connectivityManager.allNetworks.firstOrNull(::isWifi)
            ?: return false
        return bindNetwork(wifi)
    }

    @Synchronized
    private fun bindNetwork(network: Network): Boolean {
        if (!isWifi(network)) return false
        if (!bindProcess(network)) return false
        boundWifi = network
        return true
    }

    @Suppress("DEPRECATION")
    private fun bindProcess(network: Network?): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            connectivityManager.bindProcessToNetwork(network)
        } else {
            ConnectivityManager.setProcessDefaultNetwork(network)
        }

    private fun isWifi(network: Network): Boolean =
        connectivityManager.getNetworkCapabilities(network)
            ?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true

    private fun bindingDetails(): Map<String, Any> {
        val network = boundWifi
            ?: return mapOf("bound" to false, "detail" to "Wi-Fi not bound")
        val addresses = connectivityManager.getLinkProperties(network)
            ?.linkAddresses
            ?.map { it.address.hostAddress ?: it.toString() }
            ?: emptyList()
        return mapOf(
            "bound" to true,
            "detail" to "Android process bound to Wi-Fi",
            "addresses" to addresses,
        )
    }
}
