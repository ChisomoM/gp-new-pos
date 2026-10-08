package com.geepay.geepay_pos;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Looper;
import android.os.RemoteException;
import android.util.Log;

import com.topwise.cloudpos.aidl.printer.Align;
import com.topwise.cloudpos.aidl.printer.AidlPrinter;
import com.topwise.cloudpos.aidl.printer.AidlPrinterListener;
import com.topwise.cloudpos.aidl.printer.ImageUnit;
import com.topwise.cloudpos.aidl.printer.PrintTemplate;
import com.topwise.cloudpos.aidl.printer.TextUnit;
import com.topwise.cloudpos.service.DeviceServiceManager;

import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

/**
 * Topwise built-in-printer backend. Only used when this device is running on
 * Topwise POS hardware -- see {@link #getPrinterIfAvailable()}. Mirrors the
 * field layout of MainActivity's Trendit printReceipt / printZescoReceipt /
 * printDailySummary methods, translated to the Topwise AidlPrinter/PrintTemplate
 * API instead of sharing code with that (untouched) Trendit path.
 */
final class TopwisePrinterHelper {

    private static final String TAG = "TopwisePrinterHelper";
    private static final Handler MAIN_HANDLER = new Handler(Looper.getMainLooper());

    private TopwisePrinterHelper() {
    }

    /** Returns the Topwise printer manager if this is Topwise POS hardware, else null. */
    static AidlPrinter getPrinterIfAvailable() {
        try {
            return DeviceServiceManager.getInstance().getPrintManager();
        } catch (Throwable t) {
            Log.w(TAG, "Topwise print manager unavailable", t);
            return null;
        }
    }

    static void printReceipt(Context context, AidlPrinter printer, Map<String, String> receiptDetails,
            MethodChannel.Result result) {
        String isReprintFlag = receiptDetails.get("isReprint");
        boolean isReprint = isReprintFlag != null && isReprintFlag.equals("true");
        String reprintCountStr = receiptDetails.get("reprintCount");
        int reprintCount = 1;
        try {
            reprintCount = Integer.parseInt(reprintCountStr);
        } catch (Exception ignored) {
        }

        PrintTemplate template = beginTemplate(context);
        addLine(template, receiptDetails.get("businessName"), TextUnit.TextSize.XLARGE, Align.CENTER);
        addLine(template, receiptDetails.get("branchName"), TextUnit.TextSize.LARGE, Align.CENTER);
        addBlank(template);
        addLine(template, "Cashier: " + receiptDetails.get("username"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Amount: " + receiptDetails.get("amount"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Phone: " + receiptDetails.get("phone"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Payment Channel: " + receiptDetails.get("paymentChannel"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Transaction ID: " + receiptDetails.get("transactionId"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Date: " + receiptDetails.get("date"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Status: " + receiptDetails.get("status"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addBlank(template);
        if (isReprint) {
            addLine(template, "*** REPRINT COPY ***", TextUnit.TextSize.NORMAL, Align.CENTER);
            addLine(template, "Printed " + reprintCount + " time(s)", TextUnit.TextSize.SMALL, Align.CENTER);
            addBlank(template);
        }
        addDivider(template);
        addLine(template, "Thank you for your purchase!", TextUnit.TextSize.NORMAL, Align.CENTER);
        addBlank(template);
        addLine(template, "Powered by", TextUnit.TextSize.NORMAL, Align.CENTER);
        addLogo(context, template);
        addBlank(template);
        addBlank(template);

        finishPrint(printer, template, result, "Receipt printed successfully", "Failed to print receipt");
    }

    static void printZescoReceipt(Context context, AidlPrinter printer, Map<String, String> receiptDetails,
            MethodChannel.Result result) {
        PrintTemplate template = beginTemplate(context);
        addLine(template, receiptDetails.get("businessName"), TextUnit.TextSize.XLARGE, Align.CENTER);
        addLine(template, receiptDetails.get("branchName"), TextUnit.TextSize.LARGE, Align.CENTER);
        addBlank(template);
        addLine(template, "Cashier: " + receiptDetails.get("username"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Customer Name: " + receiptDetails.get("customerName"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Address: " + receiptDetails.get("address"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Token: " + receiptDetails.get("token"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Meter Number: " + receiptDetails.get("meterNumber"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Number of Units: " + receiptDetails.get("numberOfUnits"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Kwh Amount: " + receiptDetails.get("kwhAmount"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Amount Paid: " + receiptDetails.get("amountPaid"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "VAT: " + receiptDetails.get("vat"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Voucher Serial: " + receiptDetails.get("serialNumber"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Transaction Date: " + receiptDetails.get("date"), TextUnit.TextSize.NORMAL, Align.LEFT);
        addDivider(template);
        addBlank(template);
        addLine(template, "Thank you for your purchase!", TextUnit.TextSize.NORMAL, Align.CENTER);
        addBlank(template);
        addLine(template, "Powered by", TextUnit.TextSize.NORMAL, Align.CENTER);
        addLogo(context, template);
        addBlank(template);
        addBlank(template);

        finishPrint(printer, template, result, "Zesco receipt printed successfully", "Failed to print Zesco receipt");
    }

    static void printDailySummary(Context context, AidlPrinter printer, List<Map<String, String>> transactions,
            MethodChannel.Result result) {
        int successCount = 0;
        int failedCount = 0;
        int totalCount = 0;
        double totalAmount = 0.0;

        PrintTemplate template = beginTemplate(context);
        addLine(template, "Daily Transaction Summary", TextUnit.TextSize.LARGE, Align.CENTER);
        addBlank(template);

        for (Map<String, String> txn : transactions) {
            totalCount++;
            addLine(template, "Business: " + txn.get("businessName"), TextUnit.TextSize.NORMAL, Align.LEFT);
            addLine(template, "Cashier: " + txn.get("cashier"), TextUnit.TextSize.NORMAL, Align.LEFT);
            addLine(template, "ID: " + txn.get("transactionId"), TextUnit.TextSize.NORMAL, Align.LEFT);
            addLine(template, "Amount: K" + txn.get("amount"), TextUnit.TextSize.NORMAL, Align.LEFT);
            addLine(template, "Network: " + txn.get("network"), TextUnit.TextSize.NORMAL, Align.LEFT);
            addLine(template, "Status: " + txn.get("status"), TextUnit.TextSize.NORMAL, Align.LEFT);
            addLine(template, "Date: " + txn.get("date"), TextUnit.TextSize.NORMAL, Align.LEFT);
            addDivider(template);
            addBlank(template);

            String status = txn.get("status");
            String amountStr = txn.get("amount");
            if ("successful".equalsIgnoreCase(status)) {
                try {
                    totalAmount += Double.parseDouble(amountStr);
                    successCount++;
                } catch (NumberFormatException e) {
                    // matches existing Trendit behavior: skip unparsable amounts
                }
            } else if ("failed".equalsIgnoreCase(status)) {
                failedCount++;
            }
        }

        addLine(template, "--- Summary Totals ---", TextUnit.TextSize.NORMAL, Align.LEFT);
        addBlank(template);
        addLine(template, "Total Transactions: " + totalCount, TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Successful Transactions: " + successCount, TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, "Failed Transactions: " + failedCount, TextUnit.TextSize.NORMAL, Align.LEFT);
        addLine(template, String.format("Total Amount(Successful): ZMW %.2f", totalAmount), TextUnit.TextSize.NORMAL, Align.LEFT);
        addBlank(template);
        addLine(template, "Thank you!", TextUnit.TextSize.NORMAL, Align.CENTER);
        addBlank(template);

        finishPrint(printer, template, result, "Summary printed", "Could not print summary");
    }

    private static PrintTemplate beginTemplate(Context context) {
        PrintTemplate template = PrintTemplate.getInstance();
        template.init(context, null);
        template.clear();
        return template;
    }

    private static void addLine(PrintTemplate template, String text, int size, Align align) {
        template.add(new TextUnit(text == null ? "" : text, size, align).setBold(false));
    }

    private static void addBlank(PrintTemplate template) {
        template.add(new TextUnit("\n"));
    }

    private static void addDivider(PrintTemplate template) {
        template.add(new TextUnit("------------------------------------------------", TextUnit.TextSize.SMALL, Align.CENTER)
                .setBold(false));
    }

    private static void addLogo(Context context, PrintTemplate template) {
        Bitmap originalBitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.logo);
        if (originalBitmap == null) {
            return;
        }
        int printerWidth = 100;
        int scaledHeight = (int) (originalBitmap.getHeight() * ((float) printerWidth / originalBitmap.getWidth()));
        Bitmap resizedBitmap = Bitmap.createScaledBitmap(originalBitmap, printerWidth, scaledHeight, false);
        template.add(new ImageUnit(Align.CENTER, resizedBitmap, printerWidth, scaledHeight));
    }

    private static void finishPrint(AidlPrinter printer, PrintTemplate template, MethodChannel.Result result,
            String successMessage, String failureMessage) {
        try {
            Bitmap receiptBitmap = template.getPrintBitmap();
            printer.setPrinterGray(3);
            printer.addRuiImage(receiptBitmap, 0);
            printer.printRuiQueue(new AidlPrinterListener.Stub() {
                @Override
                public void onPrintFinish() throws RemoteException {
                    MAIN_HANDLER.post(() -> result.success(successMessage));
                }

                @Override
                public void onError(int errorCode) throws RemoteException {
                    MAIN_HANDLER.post(() -> result.error("PRINT_FAILED", failureMessage + " (code " + errorCode + ")", null));
                }
            });
        } catch (RemoteException e) {
            Log.e(TAG, "Topwise print failed", e);
            MAIN_HANDLER.post(() -> result.error("PRINT_FAILED", failureMessage, null));
        }
    }
}
