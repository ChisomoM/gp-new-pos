package com.example.verygoodcore.geepay_pos

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import com.topwise.cloudpos.aidl.printer.AidlPrinter
import com.trendit.basesdk.POSDeviceManager
import com.trendit.basesdk.device.printer.OnPrintTaskListener
import com.trendit.basesdk.device.printer.PrinterConstants
import com.trendit.basesdk.device.printer.PrinterDevice
import com.trendit.basesdk.device.printer.format.BitmapFormat
import com.trendit.basesdk.device.printer.format.PrintAlign
import com.trendit.basesdk.device.printer.format.PrintFontSize
import com.trendit.basesdk.device.printer.format.TextFormat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges Dart's `PrintHelper` (see lib/utils/print_helper.dart) to this
 * device's built-in POS thermal printer. Tries Topwise hardware first (see
 * [TopwisePrinterHelper]) and falls back to the inline Trendit
 * [printerDevice] calls below -- the two built-in SDKs are mutually
 * exclusive per physical device, so at most one of the two paths is ever
 * actually live on a given terminal.
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "TrenditPrinter"
    }

    private val printChannel = "geepay_pos/print"

    private var printerDevice: PrinterDevice? = null
    private val printerHelper = PrinterHelper(this)

    /**
     * Maps a Trendit `OnPrintTaskListener#onPrintResult` status code (see
     * [PrinterConstants]) to a human-readable reason. The SDK only ever hands
     * back this int -- there is no separate exception/message -- so without
     * this mapping every failure surfaces to Dart as the same opaque
     * "Failed to print receipt" with no detail.
     */
    private fun trenditTaskFailureReason(status: Int): String = when (status) {
        PrinterConstants.TASK_STATUS_OUT_OF_PAPER -> "Printer is out of paper"
        PrinterConstants.TASK_STATUS_OVER_HEAT -> "Printer is overheating"
        PrinterConstants.TASK_STATUS_LOW_POWER -> "Printer battery is too low"
        PrinterConstants.TASK_STATUS_CANCEL -> "Print task was cancelled"
        PrinterConstants.TASK_STATUS_ERR -> "Printer reported a general error"
        PrinterConstants.TASK_STATUS_FAIL -> "Printer reported a failure"
        else -> "Unknown printer error (status code $status)"
    }

    private fun failTrenditPrint(
        result: MethodChannel.Result,
        statusCode: Int,
        baseMessage: String,
    ) {
        val reason = trenditTaskFailureReason(statusCode)
        Log.e(TAG, "$baseMessage: $reason (status code $statusCode)")
        result.error("PRINT_FAILED", "$baseMessage: $reason", statusCode)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        printerDevice = try {
            POSDeviceManager.getInstance()?.printerDevice
        } catch (e: Throwable) {
            null
        }

        setupPrintChannel(flutterEngine)
    }

    private fun setupPrintChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, printChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "printReceipt" -> {
                        @Suppress("UNCHECKED_CAST")
                        val arguments = call.arguments as Map<String, String>
                        printReceipt(arguments, result)
                    }
                    "printZesco" -> {
                        @Suppress("UNCHECKED_CAST")
                        val arguments = call.arguments as Map<String, String>
                        printZescoReceipt(arguments, result)
                    }
                    "printDailySummary" -> {
                        @Suppress("UNCHECKED_CAST")
                        val transactions = call.arguments as List<Map<String, String>>
                        printDailySummary(transactions, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun printReceipt(receiptDetails: Map<String, String>, result: MethodChannel.Result) {
        val topwisePrinter = TopwisePrinterHelper.getPrinterIfAvailable()
        if (topwisePrinter != null) {
            TopwisePrinterHelper.printReceipt(this, topwisePrinter, receiptDetails, result)
            return
        }

        val device = printerDevice
        if (device != null) {
            device.clear()
            val isReprint = receiptDetails["isReprint"] == "true"
            val reprintCount = receiptDetails["reprintCount"]?.toIntOrNull() ?: 1
            val businessName = receiptDetails["businessName"]
            val cashierName = receiptDetails["username"]

            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_EXTRA_LARGE),
                "$businessName\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                "${receiptDetails["branchName"]}\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Cashier: $cashierName\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Amount: ${receiptDetails["amount"]}\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Phone: ${receiptDetails["phone"]}\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Payment Channel: ${receiptDetails["paymentChannel"]}\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Transaction ID: ${receiptDetails["transactionId"]}\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Date: ${receiptDetails["date"]}\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Status: ${receiptDetails["status"]}\n\n",
            )

            device.printText(null, "\n\n")
            if (isReprint) {
                device.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "*** REPRINT COPY ***\n",
                )
                device.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_SMALL),
                    "Printed $reprintCount time(s)\n\n",
                )
            }

            device.printDottedLines(null, 1)
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Thank you for your purchase!\n\n\n",
            )

            val originalBitmap = BitmapFactory.decodeResource(resources, R.drawable.logo)
            if (originalBitmap != null) {
                val printerWidth = 100
                val resizedBitmap = Bitmap.createScaledBitmap(
                    originalBitmap,
                    printerWidth,
                    (originalBitmap.height * (printerWidth.toFloat() / originalBitmap.width)).toInt(),
                    false,
                )
                val bitmapFormat = BitmapFormat()
                bitmapFormat.align = PrintAlign.FORMAT_ALIGN_CENTER
                device.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "Powered by ",
                )
                device.printBitmap(bitmapFormat, resizedBitmap)
            }

            device.printText(null, "\n\n")
            device.printText(null, "\n\n\n\n\n")
            device.startPrint(
                object : OnPrintTaskListener() {
                    override fun onPrintResult(i: Int) {
                        runOnUiThread {
                            if (i == PrinterConstants.TASK_STATUS_SUCCESS) {
                                result.success("Receipt printed successfully")
                            } else {
                                failTrenditPrint(result, i, "Failed to print receipt")
                            }
                        }
                    }
                },
            )
        } else {
            result.error("UNAVAILABLE", "Printer not available", null)
        }
    }

    private fun printZescoReceipt(receiptDetails: Map<String, String>, result: MethodChannel.Result) {
        val topwisePrinter = TopwisePrinterHelper.getPrinterIfAvailable()
        if (topwisePrinter != null) {
            TopwisePrinterHelper.printZescoReceipt(this, topwisePrinter, receiptDetails, result)
            return
        }

        val device = printerDevice
        if (device != null) {
            device.clear()

            val businessName = receiptDetails["businessName"]
            val token = receiptDetails["token"]
            val meterNumber = receiptDetails["meterNumber"]
            val numberOfUnits = receiptDetails["numberOfUnits"]
            val amountPaid = receiptDetails["amountPaid"]
            val vat = receiptDetails["vat"]
            val transactionDate = receiptDetails["date"]
            val cashierName = receiptDetails["username"]
            val customerName = receiptDetails["customerName"]
            val address = receiptDetails["address"]
            val serialNumber = receiptDetails["serialNumber"]
            val kwhAmount = receiptDetails["kwhAmount"]

            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_EXTRA_LARGE),
                "$businessName\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                "${receiptDetails["branchName"]}\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Cashier: $cashierName\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Customer Name: $customerName\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Address: $address\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Token: $token\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Meter Number: $meterNumber\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Number of Units: $numberOfUnits\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Kwh Amount: $kwhAmount\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Amount Paid: $amountPaid\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "VAT: $vat\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Voucher Serial: $serialNumber\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Transaction Date: $transactionDate\n\n",
            )

            device.printDottedLines(null, 1)
            device.printText(null, "\n\n")
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Thank you for your purchase!\n\n\n",
            )

            val originalBitmap = BitmapFactory.decodeResource(resources, R.drawable.logo)
            if (originalBitmap != null) {
                val printerWidth = 100
                val resizedBitmap = Bitmap.createScaledBitmap(
                    originalBitmap,
                    printerWidth,
                    (originalBitmap.height * (printerWidth.toFloat() / originalBitmap.width)).toInt(),
                    false,
                )
                val bitmapFormat = BitmapFormat()
                bitmapFormat.align = PrintAlign.FORMAT_ALIGN_CENTER
                device.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "Powered by ",
                )
                device.printBitmap(bitmapFormat, resizedBitmap)
            }

            device.printText(null, "\n\n")
            device.printText(null, "\n\n\n\n\n")

            device.startPrint(
                object : OnPrintTaskListener() {
                    override fun onPrintResult(i: Int) {
                        runOnUiThread {
                            if (i == PrinterConstants.TASK_STATUS_SUCCESS) {
                                result.success("Zesco receipt printed successfully")
                            } else {
                                failTrenditPrint(result, i, "Failed to print Zesco receipt")
                            }
                        }
                    }
                },
            )
        } else {
            result.error("UNAVAILABLE", "Printer not available", null)
        }
    }

    private fun printDailySummary(transactions: List<Map<String, String>>, result: MethodChannel.Result) {
        val topwisePrinter = TopwisePrinterHelper.getPrinterIfAvailable()
        if (topwisePrinter != null) {
            TopwisePrinterHelper.printDailySummary(this, topwisePrinter, transactions, result)
            return
        }

        val device = printerDevice
        if (device != null) {
            device.clear()

            var successCount = 0
            var totalAmount = 0.0
            var failedCount = 0
            var totalCount = 0

            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                "Daily Transaction Summary\n\n",
            )

            for (txn in transactions) {
                totalCount++

                device.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "Business: ${txn["businessName"]}\n\n",
                )
                device.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "Cashier: ${txn["cashier"]}\n\n",
                )
                device.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "ID: ${txn["transactionId"]}\n\n",
                )
                device.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "Amount: K${txn["amount"]}\n\n",
                )
                device.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "Network: ${txn["network"]}\n\n",
                )
                device.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "Status: ${txn["status"]}\n\n",
                )
                device.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "Date: ${txn["date"]}\n\n",
                )

                device.printDottedLines(null, 1)
                device.printText(null, "\n\n")

                val status = txn["status"]
                val amountStr = txn["amount"]

                if (status.equals("successful", ignoreCase = true)) {
                    val amt = amountStr?.toDoubleOrNull()
                    if (amt != null) {
                        totalAmount += amt
                        successCount++
                    }
                } else if (status.equals("failed", ignoreCase = true)) {
                    failedCount++
                }
            }

            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "\n--- Summary Totals ---\n\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Total Transactions: $totalCount\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Successful Transactions: $successCount\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Failed Transactions: $failedCount\n\n",
            )
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Total Amount(Successful): ZMW ${"%.2f".format(totalAmount)}\n",
            )
            device.printText(null, "\n\n")
            device.printText(
                getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                "Thank you!\n\n\n",
            )
            device.printText(null, "\n\n")
            device.startPrint(
                object : OnPrintTaskListener() {
                    override fun onPrintResult(i: Int) {
                        runOnUiThread {
                            if (i == PrinterConstants.TASK_STATUS_SUCCESS) {
                                result.success("Summary printed")
                            } else {
                                failTrenditPrint(result, i, "Could not print summary")
                            }
                        }
                    }
                },
            )
        } else {
            result.error("UNAVAILABLE", "Printer not available", null)
        }
    }

    private fun getTextFormat(align: PrintAlign, fontSize: Int): TextFormat {
        val format = TextFormat()
        format.align = align
        format.fontSize = fontSize
        return format
    }
}
