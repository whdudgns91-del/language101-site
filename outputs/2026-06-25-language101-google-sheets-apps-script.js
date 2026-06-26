const SPREADSHEET_ID = "171p-HbzpCn6QyBiH8iILkQwp-96M7BeKyzlurxm-Z1I";
const SHEET_NAME = "로그인 로그";
const MANAGER_EMAIL = "whdudgns91@gmail.com";

function doPost(e) {
  const sheet = SpreadsheetApp.openById(SPREADSHEET_ID).getSheetByName(SHEET_NAME);
  const payload = JSON.parse(e.postData.contents || "{}");
  if (payload.action === "poll_closed") {
    MailApp.sendEmail({
      to: MANAGER_EMAIL,
      subject: "[언어교환101] 투표 마감 명단 - " + (payload.event || ""),
      body: payload.detail || "마감된 투표 명단이 없습니다."
    });
  }
  sheet.appendRow([
    payload.timestamp || new Date().toISOString(),
    payload.memberId || "",
    payload.name || "",
    payload.birth || "",
    payload.action || "",
    payload.event || "",
    payload.option || "",
    payload.points || 0,
    payload.level || 1,
    payload.attendance || 0,
    payload.hearts || 0,
    payload.sentHearts || 0,
    payload.detail || ""
  ]);
  return ContentService
    .createTextOutput(JSON.stringify({ ok: true }))
    .setMimeType(ContentService.MimeType.JSON);
}
