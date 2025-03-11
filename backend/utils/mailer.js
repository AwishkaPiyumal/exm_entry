import nodemailer from "nodemailer";

const transporter = nodemailer.createTransport({
  host: "smtp.ethereal.email",
  port: 587,
  secure: false, // true for port 465, false for other ports
  service: "gmail",
  auth: {
    user: process.env.EMAIL,
    pass: process.env.EMAIL_PASS,
  },
});

const mailer = async (receiver, subject, htmlContent) => {
  try {
    const info = await transporter.sendMail({
      from: `"Examination Branch" <${process.env.EMAIL}>`,
      to: receiver,
      subject,
      html: htmlContent,
    });
    console.log("Message sent: %s", info.messageId);
  } catch (error) {
    console.error("Error sending email:", error);
    throw new Error("Failed to send email.");
  }
};

export default mailer;
