const SPREADSHEET_ID = "171p-HbzpCn6QyBiH8iILkQwp-96M7BeKyzlurxm-Z1I";
const MANAGER_EMAIL = "whdudgns91@gmail.com";

function doPost(e) {
  const payload = JSON.parse(e.postData.contents || "{}");
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const sheet = ss.getSheets()[0];
  console.log("Language101 payload", JSON.stringify(payload));

  if (Array.isArray(payload.attendees)) {
    return handleAttendanceSync_(sheet, payload);
  }

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

function handleAttendanceSync_(sheet, payload) {
  const studyDate = normalizeStudyDate_(payload.study_date);
  const attendees = payload.attendees || [];
  const updated = [];
  const duplicated = [];
  const unmatched = [];
  console.log("Language101 attendance sync", JSON.stringify({
    spreadsheetId: SPREADSHEET_ID,
    sheetName: sheet.getName(),
    study_date: studyDate,
    study_title: payload.study_title || "",
    attendeeCount: attendees.length
  }));

  const lastRow = Math.max(sheet.getLastRow(), 1);
  const names = sheet.getRange(1, 1, lastRow, 1).getValues().map(function(row) {
    return String(row[0] || "").trim();
  });
  const nameToRow = {};
  names.forEach(function(name, index) {
    if (!name) return;
    nameToRow[normalizeName_(name)] = index + 1;
  });

  attendees.forEach(function(attendee) {
    if (!attendee || !attendee.attended) return;
    const name = String(attendee.name || "").trim();
    const row = nameToRow[normalizeName_(name)];
    if (!row) {
      unmatched.push(name);
      return;
    }

    const cell = sheet.getRange(row, 8);
    const current = String(cell.getValue() || "");
    if (hasStudyDate_(current, studyDate)) {
      duplicated.push(name);
      return;
    }

    cell.setValue(appendStudyDate_(current, studyDate));
    updated.push(name);
  });

  const result = {
    ok: true,
    study_date: studyDate,
    study_title: payload.study_title || "",
    updated: updated,
    duplicated: duplicated,
    unmatched: unmatched
  };
  console.log("Language101 attendance result", JSON.stringify(result));

  return ContentService
    .createTextOutput(JSON.stringify(result))
    .setMimeType(ContentService.MimeType.JSON);
}

function normalizeName_(value) {
  return String(value || "").trim().toLowerCase().replace(/\s+/g, " ");
}

function normalizeStudyDate_(value) {
  const text = String(value || "").trim();
  const slash = text.match(/^(\d{1,2})\/(\d{1,2})$/);
  if (slash) return Number(slash[1]) + "월" + Number(slash[2]) + "일";
  const korean = text.match(/^(\d{1,2})월\s*(\d{1,2})일/);
  if (korean) return Number(korean[1]) + "월" + Number(korean[2]) + "일";
  return text;
}

function hasStudyDate_(current, studyDate) {
  return String(current || "")
    .split(",")
    .map(function(item) { return item.trim(); })
    .filter(Boolean)
    .indexOf(studyDate) !== -1;
}

function appendStudyDate_(current, studyDate) {
  const text = String(current || "").trim();
  if (!text) return studyDate + ",";
  return text.replace(/,*\s*$/, "") + "," + studyDate + ",";
}
