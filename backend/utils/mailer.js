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

const mailer = async (receiver, user_name, password) => {
  try {
    const info = await transporter.sendMail({
      from: `"Examination Branch" <${process.env.EMAIL}>`,
      to: receiver,
      subject: "Registration succesfull",
      html: `<h2>You are successfully registered for to examinations</h2>
              <h4>User name : ${user_name}</h4>
              <h4>User name : ${password}</h4>`,
    });
    console.log("Message sent: %s", info.messageId);
  } catch (error) {
    return error;
  }
};

export default mailer;
