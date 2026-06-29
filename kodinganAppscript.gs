const SHEET_PESANAN = "Sheet1"; 
const SHEET_LOGIN = "info login";

function doPost(e) {
  var output = ContentService.createTextOutput();
  output.setMimeType(ContentService.MimeType.JSON);
  try {
    const data = JSON.parse(e.postData.contents);
    const action = data.action || "pesan";
    if (action === "login") {
      return output.setContent(JSON.stringify(handleLogin(data)));
    } else {
      return output.setContent(JSON.stringify(handlePesanan(data)));
    }
  } catch (err) {
    return output.setContent(JSON.stringify({status: "error", message: err.toString()}));
  }
}

function doGet(e) {
  var output = ContentService.createTextOutput();
  output.setMimeType(ContentService.MimeType.JSON);
  const action = e?.parameter?.action || "getPesanan";
  const ss = SpreadsheetApp.getActiveSpreadsheet();

  if (action === "getLogin") {
    const sheetLogin = ss.getSheetByName(SHEET_LOGIN);
    if (!sheetLogin) return output.setContent(JSON.stringify([]));
    const data = sheetLogin.getDataRange().getValues();
    data.shift(); 
    return output.setContent(JSON.stringify(data));
  } else {
    const sheetPesanan = ss.getSheetByName(SHEET_PESANAN);
    if (!sheetPesanan) return output.setContent(JSON.stringify([]));
    const data = sheetPesanan.getDataRange().getValues();
    data.shift(); 
    return output.setContent(JSON.stringify(data));
  }
}

function handleLogin(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let sheetLogin = ss.getSheetByName(SHEET_LOGIN);
  if (!sheetLogin) {
    sheetLogin = ss.insertSheet(SHEET_LOGIN);
    sheetLogin.appendRow(["Waktu", "Nama", "Peran", "Status"]);
  }
  sheetLogin.appendRow([new Date(), data.nama || "-", data.peran || "-", data.status || "Berhasil Login"]);
  return { status: "success", message: "Login tercatat" };
}

function handlePesanan(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let sheetPesanan = ss.getSheetByName(SHEET_PESANAN);
  if (!sheetPesanan) {
    sheetPesanan = ss.insertSheet(SHEET_PESANAN);
    sheetPesanan.appendRow(["Waktu", "Nama", "Meja", "Menu", "Total", "Pembayaran"]);
  }
  sheetPesanan.appendRow([new Date(), data.nama || "-", data.meja || "-", data.menu || "-", data.total || 0, data.pembayaran || "Cash"]);
  return { status: "success", message: "Pesanan tersimpan" };
}