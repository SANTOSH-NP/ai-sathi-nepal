const { PDFDocument, rgb, StandardFonts } = require('pdf-lib');

function generateCvHtml(templateType, data) {
  switch (templateType) {
    case 'europass':
      return generateEuropassHtml(data);
    case 'ats':
      return generateAtsHtml(data);
    case 'modern':
      return generateModernHtml(data);
    default:
      return generateAtsHtml(data);
  }
}

function generateEuropassHtml(data) {
  const { personalInfo, education, experience, skills, languages, certifications } = data;
  return `<!DOCTYPE html>
<html>
<head>
<style>
  body { font-family: Arial, sans-serif; margin: 40px; color: #333; font-size: 11pt; }
  .header { border-bottom: 3px solid #003399; padding-bottom: 10px; margin-bottom: 20px; }
  .name { font-size: 24pt; color: #003399; font-weight: bold; }
  .contact { color: #666; margin-top: 5px; }
  .section { margin-bottom: 20px; }
  .section-title { font-size: 14pt; color: #003399; border-bottom: 1px solid #003399; padding-bottom: 3px; margin-bottom: 10px; }
  .item { margin-bottom: 12px; display: flex; }
  .item-date { width: 150px; color: #666; flex-shrink: 0; }
  .item-content { flex: 1; }
  .item-title { font-weight: bold; }
  .skills-grid { display: flex; flex-wrap: wrap; gap: 8px; }
  .skill-tag { background: #e8eef7; padding: 4px 12px; border-radius: 3px; font-size: 10pt; }
</style>
</head>
<body>
  <div class="header">
    <div class="name">${personalInfo.fullName}</div>
    <div class="contact">
      ${personalInfo.email} | ${personalInfo.phone}
      ${personalInfo.address ? ` | ${personalInfo.address}` : ''}
      ${personalInfo.linkedIn ? ` | ${personalInfo.linkedIn}` : ''}
    </div>
  </div>

  ${personalInfo.summary ? `
  <div class="section">
    <div class="section-title">PERSONAL STATEMENT</div>
    <p>${personalInfo.summary}</p>
  </div>` : ''}

  ${experience.length ? `
  <div class="section">
    <div class="section-title">WORK EXPERIENCE</div>
    ${experience.map((exp) => `
    <div class="item">
      <div class="item-date">${exp.startDate} - ${exp.current ? 'Present' : exp.endDate}</div>
      <div class="item-content">
        <div class="item-title">${exp.position}</div>
        <div>${exp.company}</div>
        ${exp.description ? `<p>${exp.description}</p>` : ''}
      </div>
    </div>`).join('')}
  </div>` : ''}

  ${education.length ? `
  <div class="section">
    <div class="section-title">EDUCATION AND TRAINING</div>
    ${education.map((edu) => `
    <div class="item">
      <div class="item-date">${edu.startDate} - ${edu.endDate || 'Present'}</div>
      <div class="item-content">
        <div class="item-title">${edu.degree}${edu.field ? ` in ${edu.field}` : ''}</div>
        <div>${edu.institution}</div>
        ${edu.grade ? `<div>Grade: ${edu.grade}</div>` : ''}
      </div>
    </div>`).join('')}
  </div>` : ''}

  ${skills.length ? `
  <div class="section">
    <div class="section-title">SKILLS</div>
    <div class="skills-grid">
      ${skills.map((skill) => `<span class="skill-tag">${skill}</span>`).join('')}
    </div>
  </div>` : ''}

  ${languages.length ? `
  <div class="section">
    <div class="section-title">LANGUAGES</div>
    ${languages.map((lang) => `<div>${lang.language}: ${lang.proficiency}</div>`).join('')}
  </div>` : ''}

  ${certifications?.length ? `
  <div class="section">
    <div class="section-title">CERTIFICATIONS</div>
    ${certifications.map((cert) => `
    <div class="item">
      <div class="item-date">${cert.date || ''}</div>
      <div class="item-content">
        <div class="item-title">${cert.name}</div>
        ${cert.issuer ? `<div>${cert.issuer}</div>` : ''}
      </div>
    </div>`).join('')}
  </div>` : ''}
</body>
</html>`;
}

function generateAtsHtml(data) {
  const { personalInfo, education, experience, skills, languages, certifications } = data;
  return `<!DOCTYPE html>
<html>
<head>
<style>
  body { font-family: 'Times New Roman', serif; margin: 40px; color: #000; font-size: 11pt; line-height: 1.4; }
  .name { font-size: 20pt; font-weight: bold; text-align: center; }
  .contact { text-align: center; margin-bottom: 15px; }
  .section-title { font-size: 12pt; font-weight: bold; text-transform: uppercase; border-bottom: 1px solid #000; margin: 15px 0 8px; padding-bottom: 2px; }
  .item { margin-bottom: 8px; }
  .item-header { display: flex; justify-content: space-between; }
  .item-title { font-weight: bold; }
  .item-date { font-style: italic; }
  ul { margin: 3px 0; padding-left: 20px; }
  li { margin-bottom: 2px; }
</style>
</head>
<body>
  <div class="name">${personalInfo.fullName}</div>
  <div class="contact">
    ${personalInfo.email} | ${personalInfo.phone}
    ${personalInfo.address ? ` | ${personalInfo.address}` : ''}
    ${personalInfo.linkedIn ? ` | ${personalInfo.linkedIn}` : ''}
    ${personalInfo.website ? ` | ${personalInfo.website}` : ''}
  </div>

  ${personalInfo.summary ? `
  <div class="section-title">SUMMARY</div>
  <p>${personalInfo.summary}</p>` : ''}

  ${experience.length ? `
  <div class="section-title">PROFESSIONAL EXPERIENCE</div>
  ${experience.map((exp) => `
  <div class="item">
    <div class="item-header">
      <span class="item-title">${exp.position} - ${exp.company}</span>
      <span class="item-date">${exp.startDate} - ${exp.current ? 'Present' : exp.endDate}</span>
    </div>
    ${exp.description ? `<ul><li>${exp.description}</li></ul>` : ''}
  </div>`).join('')}` : ''}

  ${education.length ? `
  <div class="section-title">EDUCATION</div>
  ${education.map((edu) => `
  <div class="item">
    <div class="item-header">
      <span class="item-title">${edu.degree}${edu.field ? ` in ${edu.field}` : ''} - ${edu.institution}</span>
      <span class="item-date">${edu.startDate} - ${edu.endDate || 'Present'}</span>
    </div>
    ${edu.grade ? `<div>GPA/Grade: ${edu.grade}</div>` : ''}
  </div>`).join('')}` : ''}

  ${skills.length ? `
  <div class="section-title">SKILLS</div>
  <p>${skills.join(' | ')}</p>` : ''}

  ${certifications?.length ? `
  <div class="section-title">CERTIFICATIONS</div>
  ${certifications.map((cert) => `<div>${cert.name}${cert.issuer ? ` - ${cert.issuer}` : ''}${cert.date ? ` (${cert.date})` : ''}</div>`).join('')}` : ''}

  ${languages.length ? `
  <div class="section-title">LANGUAGES</div>
  <p>${languages.map((l) => `${l.language} (${l.proficiency})`).join(' | ')}</p>` : ''}
</body>
</html>`;
}

function generateModernHtml(data) {
  const { personalInfo, education, experience, skills, languages, certifications } = data;
  return `<!DOCTYPE html>
<html>
<head>
<style>
  body { font-family: 'Helvetica Neue', Arial, sans-serif; margin: 0; color: #2d3748; font-size: 10pt; }
  .container { display: flex; min-height: 100vh; }
  .sidebar { width: 220px; background: #1a202c; color: #e2e8f0; padding: 30px 20px; }
  .main { flex: 1; padding: 30px; }
  .name { font-size: 22pt; font-weight: 700; color: #fff; margin-bottom: 5px; }
  .sidebar-section { margin-bottom: 20px; }
  .sidebar-title { font-size: 10pt; text-transform: uppercase; letter-spacing: 2px; color: #63b3ed; margin-bottom: 8px; border-bottom: 1px solid #4a5568; padding-bottom: 4px; }
  .sidebar-item { margin-bottom: 4px; font-size: 9pt; color: #cbd5e0; }
  .main-section { margin-bottom: 20px; }
  .main-title { font-size: 13pt; color: #2b6cb0; text-transform: uppercase; letter-spacing: 1px; border-bottom: 2px solid #2b6cb0; padding-bottom: 4px; margin-bottom: 10px; }
  .exp-item { margin-bottom: 12px; }
  .exp-header { display: flex; justify-content: space-between; align-items: baseline; }
  .exp-role { font-weight: 700; font-size: 11pt; }
  .exp-company { color: #2b6cb0; }
  .exp-date { color: #718096; font-size: 9pt; }
  .skill-bar { background: #4a5568; border-radius: 3px; height: 6px; margin-top: 3px; }
  .skill-fill { background: #63b3ed; border-radius: 3px; height: 6px; }
</style>
</head>
<body>
  <div class="container">
    <div class="sidebar">
      <div class="name">${personalInfo.fullName}</div>
      
      <div class="sidebar-section">
        <div class="sidebar-title">Contact</div>
        <div class="sidebar-item">${personalInfo.email}</div>
        <div class="sidebar-item">${personalInfo.phone}</div>
        ${personalInfo.address ? `<div class="sidebar-item">${personalInfo.address}</div>` : ''}
        ${personalInfo.linkedIn ? `<div class="sidebar-item">${personalInfo.linkedIn}</div>` : ''}
      </div>

      ${skills.length ? `
      <div class="sidebar-section">
        <div class="sidebar-title">Skills</div>
        ${skills.map((skill) => `<div class="sidebar-item">${skill}</div>`).join('')}
      </div>` : ''}

      ${languages.length ? `
      <div class="sidebar-section">
        <div class="sidebar-title">Languages</div>
        ${languages.map((lang) => `<div class="sidebar-item">${lang.language} - ${lang.proficiency}</div>`).join('')}
      </div>` : ''}
    </div>

    <div class="main">
      ${personalInfo.summary ? `
      <div class="main-section">
        <div class="main-title">About Me</div>
        <p>${personalInfo.summary}</p>
      </div>` : ''}

      ${experience.length ? `
      <div class="main-section">
        <div class="main-title">Experience</div>
        ${experience.map((exp) => `
        <div class="exp-item">
          <div class="exp-header">
            <div>
              <span class="exp-role">${exp.position}</span>
              <span class="exp-company"> at ${exp.company}</span>
            </div>
            <span class="exp-date">${exp.startDate} - ${exp.current ? 'Present' : exp.endDate}</span>
          </div>
          ${exp.description ? `<p>${exp.description}</p>` : ''}
        </div>`).join('')}
      </div>` : ''}

      ${education.length ? `
      <div class="main-section">
        <div class="main-title">Education</div>
        ${education.map((edu) => `
        <div class="exp-item">
          <div class="exp-header">
            <div>
              <span class="exp-role">${edu.degree}${edu.field ? ` in ${edu.field}` : ''}</span>
            </div>
            <span class="exp-date">${edu.startDate} - ${edu.endDate || 'Present'}</span>
          </div>
          <div>${edu.institution}</div>
          ${edu.grade ? `<div>Grade: ${edu.grade}</div>` : ''}
        </div>`).join('')}
      </div>` : ''}

      ${certifications?.length ? `
      <div class="main-section">
        <div class="main-title">Certifications</div>
        ${certifications.map((cert) => `
        <div class="exp-item">
          <span class="exp-role">${cert.name}</span>
          ${cert.issuer ? `<span> - ${cert.issuer}</span>` : ''}
          ${cert.date ? `<span class="exp-date"> (${cert.date})</span>` : ''}
        </div>`).join('')}
      </div>` : ''}
    </div>
  </div>
</body>
</html>`;
}

async function htmlToPdf(html) {
  // Using pdf-lib for server-side PDF generation
  // For production, consider using Puppeteer for more accurate HTML-to-PDF
  const pdfDoc = await PDFDocument.create();
  const page = pdfDoc.addPage([595, 842]); // A4 size

  const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const boldFont = await pdfDoc.embedFont(StandardFonts.HelveticaBold);

  // Simple text extraction from HTML (basic implementation)
  const textContent = html
    .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
    .replace(/<[^>]+>/g, '\n')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/\n{3,}/g, '\n\n')
    .trim();

  const lines = textContent.split('\n').filter((l) => l.trim());
  let y = 800;
  const lineHeight = 14;
  const margin = 50;

  for (const line of lines) {
    if (y < 50) {
      const newPage = pdfDoc.addPage([595, 842]);
      y = 800;
    }

    const trimmedLine = line.trim();
    if (!trimmedLine) continue;

    const isTitle = trimmedLine === trimmedLine.toUpperCase() && trimmedLine.length < 40;

    page.drawText(trimmedLine.substring(0, 80), {
      x: margin,
      y,
      size: isTitle ? 12 : 10,
      font: isTitle ? boldFont : font,
      color: rgb(0.1, 0.1, 0.1),
    });
    y -= lineHeight;
  }

  return pdfDoc.save();
}

module.exports = { generateCvHtml, htmlToPdf };
