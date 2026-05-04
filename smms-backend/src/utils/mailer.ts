import nodemailer from 'nodemailer';
import { env } from '../config/env';

export const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.sendgrid.net',
  port: Number(process.env.SMTP_PORT) || 587,
  auth: {
    user: process.env.SMTP_USER || 'apikey',
    pass: process.env.SMTP_PASS || 'your_api_key',
  },
});

export const sendOtpEmail = async (to: string, otp: string) => {
  const mailOptions = {
    from: process.env.SMTP_FROM || 'no-reply@smms.edu',
    to,
    subject: 'Your SMMS Login OTP',
    text: `Your OTP to login to SMMS is: ${otp}. It will expire in ${env.OTP_EXPIRY_MINUTES} minutes.`,
    html: `<h3>SMMS Login Passcode</h3><p>Your OTP to login to SMMS is: <b>${otp}</b></p><p>It will expire in ${env.OTP_EXPIRY_MINUTES} minutes.</p>`,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`[SMTP] Successfully sent OTP to ${to}`);
  } catch (error) {
    console.error(`[SMTP] Error sending OTP to ${to}:`, error);
    // Fallback or handle error (you could still mock it in dev if SMTP fails)
  }
};
