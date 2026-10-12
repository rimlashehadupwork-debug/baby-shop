const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const cors = require("cors")({origin: true});

admin.initializeApp();

exports.sendOtp = onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const email = req.body.email;
      if (!email) {
        return res.status(400).send({error: "Email is required"});
      }

      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      const expiresAt = Date.now() + 5 * 60 * 1000;

      const sanitizedEmail = email.replace(".", "_");
      await admin.database().ref(`otps/${sanitizedEmail}`).set({
        otp: otp,
        expiresAt: expiresAt,
      });

      const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: "rimlashehad@gmail.com",
          pass: "fiwg traf pkge pisx",
        },
      });

      await transporter.sendMail({
        from: "\"BabyShopHub\" <no-reply@babyshop.com>",
        to: email,
        subject: "Your Verification Code",
        text: `Your code is: ${otp}. Expires in 5 minutes.`,
      });

      return res.status(200).send(
          {success: true, message: "OTP sent successfully"}
      );
    } catch (error) {
      console.error("Error sending OTP:", error);
      return res.status(500).send({error: error.message});
    }
  });
});

exports.verifyOtp = onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const {email, otp} = req.body;
      if (!email || !otp) {
        return res.status(400).send(
            {error: "Email and OTP are required"}
        );
      }

      const sanitizedEmail = email.replace(".", "_");
      const snapshot = await admin.database()
          .ref(`otps/${sanitizedEmail}`).once("value");

      if (!snapshot.exists()) {
        return res.status(400).send(
            {success: false, message: "OTP not found or expired"}
        );
      }

      const data = snapshot.val();

      if (Date.now() > data.expiresAt) {
        await admin.database().ref(`otps/${sanitizedEmail}`).remove();
        return res.status(400).send(
            {success: false, message: "OTP has expired"}
        );
      }

      if (data.otp !== otp) {
        return res.status(400).send(
            {success: false, message: "Invalid OTP code"}
        );
      }

      await admin.database().ref(`otps/${sanitizedEmail}`).remove();

      return res.status(200).send(
          {success: true, message: "OTP verified successfully"}
      );
    } catch (error) {
      console.error("Error verifying OTP:", error);
      return res.status(500).send({error: error.message});
    }
  });
});