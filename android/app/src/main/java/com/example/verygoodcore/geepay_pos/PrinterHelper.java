package com.example.verygoodcore.geepay_pos;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.app.Activity;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Map;

import com.trendit.basesdk.device.printer.OnPrintTaskListener;
import com.trendit.basesdk.device.printer.PrinterConstants;
import com.trendit.basesdk.device.printer.PrinterDevice;
import com.trendit.basesdk.device.printer.format.PrintAlign;
import com.trendit.basesdk.device.printer.format.PrintFontSize;
import com.trendit.basesdk.device.printer.format.TextFormat;
import com.trendit.basesdk.device.printer.format.BitmapFormat;
import io.flutter.plugin.common.MethodChannel;

public class PrinterHelper {

    private PrinterDevice printerDevice;

    private Activity activity;  // Store the Activity context

    // Constructor to pass the Activity context
    public PrinterHelper(Activity activity) {
        this.activity = activity;
    }

    private void runOnUiThread(Runnable runnable) {
        if (activity != null) {
            activity.runOnUiThread(runnable);  // Use the Activity's runOnUiThread method
        }
    }

    private Bitmap getLogoBitmap() {
        if (activity != null) {
            return BitmapFactory.decodeResource(activity.getResources(), R.drawable.logo);  // Use activity to get resources
        }
        return null;
    }

    public void printImage(byte[] imageData, MethodChannel.Result result) {
        Bitmap originalBitmap = getLogoBitmap();  // Get the logo bitmap
        if (originalBitmap != null) {
            int printerWidth = 100;
            Bitmap resizedBitmap = Bitmap.createScaledBitmap(originalBitmap, printerWidth,
                    (int) (originalBitmap.getHeight() * ((float) printerWidth / originalBitmap.getWidth())), false);
            if (resizedBitmap != null) {
                BitmapFormat bitmapFormat = new BitmapFormat();
                bitmapFormat.setAlign(PrintAlign.FORMAT_ALIGN_CENTER);
                printerDevice.printBitmap(bitmapFormat, resizedBitmap);
            }
        }

        printerDevice.startPrint(new OnPrintTaskListener() {
            @Override
            public void onPrintResult(int status) {
                runOnUiThread(() -> {
                    if (status == PrinterConstants.TASK_STATUS_SUCCESS) {
                        result.success("Image printed successfully");
                    } else {
                        result.error("PRINT_FAILED", "Failed to print image", null);
                    }
                });
            }
        });
    }

    public void printZescoReceipt(Map<String, String> receiptDetails, MethodChannel.Result result) {
        if (printerDevice != null) {
            printerDevice.clear();

            String businessName = receiptDetails.get("businessName");
            String token = receiptDetails.get("token");
            String meterNumber = receiptDetails.get("meterNumber");
            String numberOfUnits = receiptDetails.get("numberOfUnits");
            String amountPaid = receiptDetails.get("amountPaid");
            String vat = receiptDetails.get("vat");
            String transactionDate = getPrinterTime(); // Current time for the transaction

            printerDevice.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_EXTRA_LARGE),
                    businessName + "\n\n");

            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "Token: " + token + "\n\n");

            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "Meter Number: " + meterNumber + "\n\n");

            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "Number of Units: " + numberOfUnits + "\n\n");

            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "Amount Paid: " + amountPaid + "\n\n");

            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "VAT: " + vat + "\n\n");

            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "Transaction Date: " + transactionDate + "\n\n");

            printerDevice.printDottedLines(null, 1);

            printerDevice.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "Thank you for your purchase!\n\n\n");

            Bitmap originalBitmap = getLogoBitmap();  // Get the logo bitmap
            if (originalBitmap != null) {
                int printerWidth = 100;
                Bitmap resizedBitmap = Bitmap.createScaledBitmap(originalBitmap, printerWidth,
                        (int) (originalBitmap.getHeight() * ((float) printerWidth / originalBitmap.getWidth())), false);
                if (resizedBitmap != null) {
                    BitmapFormat bitmapFormat = new BitmapFormat();
                    bitmapFormat.setAlign(PrintAlign.FORMAT_ALIGN_CENTER);
                    printerDevice.printBitmap(bitmapFormat, resizedBitmap);
                }
            }

            printerDevice.printText(null, "\n\n");
            printerDevice.printText(null, "\n\n\n\n\n");

            printerDevice.startPrint(new OnPrintTaskListener() {
                @Override
                public void onPrintResult(int i) {
                    runOnUiThread(() -> {
                        if (i == PrinterConstants.TASK_STATUS_SUCCESS) {
                            result.success("Zesco receipt printed successfully");
                        } else {
                            result.error("PRINT_FAILED", "Failed to print Zesco receipt", null);
                        }
                    });
                }
            });
        } else {
            result.error("UNAVAILABLE", "Printer not available", null);
        }
    }

    public void printReceipt(Map<String, String> receiptDetails, MethodChannel.Result result) {
        if (printerDevice != null) {
            printerDevice.clear();

            String businessName = (String) receiptDetails.get("businessName");

            printerDevice.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_EXTRA_LARGE),
                    businessName + "\n\n");

            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "Amount: " + receiptDetails.get("amount") + "\n\n");
            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "Phone: " + receiptDetails.get("phone") + "\n\n");
            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "Payment Channel: " + receiptDetails.get("paymentChannel") + "\n\n");
            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "Transaction ID: " + receiptDetails.get("transactionId") + "\n\n");
            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "Date: " + receiptDetails.get("date") + "\n\n");
            printerDevice.printText(getTextFormat(PrintAlign.FORMAT_ALIGN_LEFT, PrintFontSize.FORMAT_FONT_SIZE_LARGE),
                    "Status: " + receiptDetails.get("status") + "\n\n");

            printerDevice.printDottedLines(null, 1);
            printerDevice.printText(
                    getTextFormat(PrintAlign.FORMAT_ALIGN_CENTER, PrintFontSize.FORMAT_FONT_SIZE_MEDIUM),
                    "Thank you for your purchase!\n\n\n");

            Bitmap originalBitmap = getLogoBitmap();  // Get the logo bitmap
            if (originalBitmap != null) {
                int printerWidth = 100;
                Bitmap resizedBitmap = Bitmap.createScaledBitmap(originalBitmap, printerWidth,
                        (int) (originalBitmap.getHeight() * ((float) printerWidth / originalBitmap.getWidth())), false);
                if (resizedBitmap != null) {
                    BitmapFormat bitmapFormat = new BitmapFormat();
                    bitmapFormat.setAlign(PrintAlign.FORMAT_ALIGN_CENTER);
                    printerDevice.printBitmap(bitmapFormat, resizedBitmap);
                }
            }

            printerDevice.printText(null, "\n\n");
            printerDevice.printText(null, "\n\n\n\n\n");
            printerDevice.startPrint(new OnPrintTaskListener() {
                @Override
                public void onPrintResult(int i) {
                    runOnUiThread(() -> {
                        if (i == PrinterConstants.TASK_STATUS_SUCCESS) {
                            result.success("Receipt printed successfully");
                        } else {
                            result.error("PRINT_FAILED", "Failed to print receipt", null);
                        }
                    });
                }
            });
        } else {
            result.error("UNAVAILABLE", "Printer not available", null);
        }
    }

    private String getPrinterTime() {
        String pattern = "yyyy-MM-dd HH:mm:ss";
        SimpleDateFormat dateFormat = new SimpleDateFormat(pattern, Locale.getDefault());
        return dateFormat.format(new Date(System.currentTimeMillis()));
    }

    private TextFormat getTextFormat(PrintAlign align, int fontSize) {
        TextFormat format = new TextFormat();
        format.setAlign(align);
        format.setFontSize(fontSize);
        return format;
    }
}
