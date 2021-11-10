package com.flutterplugin.tbs_static

import android.annotation.SuppressLint
import android.os.Build
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.tencent.smtt.export.external.interfaces.SslError
import com.tencent.smtt.export.external.interfaces.SslErrorHandler
import com.tencent.smtt.export.external.interfaces.WebResourceError
import com.tencent.smtt.export.external.interfaces.WebResourceRequest
import com.tencent.smtt.sdk.QbSdk
import com.tencent.smtt.sdk.WebSettings
import com.tencent.smtt.sdk.WebView
import com.tencent.smtt.sdk.WebViewClient

const val TAG = "Xiong -- X5WebView"

class X5WebViewActivity : AppCompatActivity() {
    var webView: WebView? = null
    private lateinit var tvTitle: TextView
    private lateinit var container: LinearLayout
    var webViewTitle: String? = null
    var url = "https://www.baidu.com"
    var landspace = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        landspace = intent.getBooleanExtra("landspace", false)
//        if (landspace) {
//            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE)
//        }
        Log.d(TAG, "onCreate")
        container = LayoutInflater.from(this)
            .inflate(R.layout.activity_x5_webview, null, true) as LinearLayout
        setContentView(container)
        StatusBarUtil.setTransparencyStatusBar(this)
        StatusBarUtil.setStatusBarMode(this, true)
        initView()

        intent.getStringExtra("title")?.let { webViewTitle = it }
        intent.getStringExtra("url")?.let { url = it }
    }

    override fun onResume() {
        super.onResume()
        Log.i(TAG, "onResume")

        if (QbSdk.canLoadX5(this)) {
            Log.i(TAG, "已安装好，直接显示")
            createWebView()
        } else {
            Log.i(TAG, "新安装")
            val ok = QbSdk.preinstallStaticTbs(this)
            Log.i(TAG, "安装结果：$ok")
            createWebView()
        }

        webView?.onResume()
        webView?.resumeTimers()
    }

    override fun onPause() {
        super.onPause()
        webView?.onPause()
        webView?.pauseTimers()
    }

    private fun initView() {
        tvTitle = findViewById(R.id.tv_title)
        findViewById<ImageView>(R.id.btn_back).setOnClickListener {
            onBackPressed()
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun createWebView() {
        //手动创建WebView，显示到容器中，这样就能保证WebView一定是在X5内核准备好后创建的
        webView = WebView(applicationContext)
        val css = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.MATCH_PARENT
        )
        container.addView(webView, css)

        webView?.webViewClient = webViewClient
        webView?.webChromeClient = webChromeClient

        //移除有风险的WebView系统隐藏接口漏洞
        webView?.removeJavascriptInterface("searchBoxJavaBridge_")
        webView?.removeJavascriptInterface("accessibility")
        webView?.removeJavascriptInterface("accessibilityTraversal")

        val webSettings = webView?.settings
        webSettings?.javaScriptEnabled = true
        webSettings?.javaScriptEnabled = true
        webSettings?.domStorageEnabled = true
        webSettings?.javaScriptCanOpenWindowsAutomatically = true
        webSettings?.setSupportMultipleWindows(true)
        webSettings?.setGeolocationEnabled(false)
        webSettings?.blockNetworkImage = false
        webSettings?.setSupportZoom(true)
        webSettings?.pluginState = WebSettings.PluginState.ON
        webSettings?.useWideViewPort = true
        webSettings?.allowFileAccess = true // 允许访问文件
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            webSettings?.mixedContentMode?.let { webSettings.mixedContentMode = it }
        }

        webView?.loadUrl(url)
        Log.d(TAG, "X5WebViewActivity load $url")
    }

    var webViewClient: WebViewClient = object : WebViewClient() {
        override fun shouldOverrideUrlLoading(p0: WebView?, p1: String?): Boolean {
            Log.d(TAG, "webview shouldOverrideUrlLoading : $p1")
            p0?.loadUrl(p1)
            return false
        }

        override fun onReceivedError(p0: WebView?, p1: WebResourceRequest?, p2: WebResourceError?) {
            super.onReceivedError(p0, p1, p2)
            Log.d(
                TAG,
                "webview onReceivedError :description : ${p2?.description}  errorCode :" + p2?.errorCode
            )
        }

        override fun onReceivedSslError(p0: WebView?, p1: SslErrorHandler?, p2: SslError?) {
            Log.d(TAG, "webview onReceivedSslError : ${p2.toString()}")
//            super.onReceivedSslError(p0, p1, p2)
            p1?.proceed()
        }
    }

    var webChromeClient: com.tencent.smtt.sdk.WebChromeClient =
        object : com.tencent.smtt.sdk.WebChromeClient() {
            override fun onProgressChanged(p0: WebView?, p1: Int) {
                super.onProgressChanged(p0, p1)
                Log.d(TAG, "webview onProgressChanged : $p1")
            }

            override fun onReceivedTitle(view: WebView, title: String) {
                if (!TextUtils.isEmpty(title)) {
                    tvTitle.text = webViewTitle ?: title
                }
                super.onReceivedTitle(view, title)
            }
        }

    override fun onDestroy() {
        if (null != webView) {
            webView?.clearCache(true)
            webView?.clearHistory()
            webView?.clearFormData()
            webView?.loadUrl("about:blank")
            webView?.stopLoading()
            webView?.setWebChromeClient(null)
            webView?.setWebViewClient(null)
            webView?.destroy()
            webView = null
        }
        super.onDestroy()
        System.exit(0)
        Log.d(TAG, "onDestroy")
    }

    override fun onBackPressed() {
        val canGoBack = webView?.canGoBack() ?: false
        if (canGoBack) {
            webView?.goBack()
        } else {
            finish()
        }
    }
}