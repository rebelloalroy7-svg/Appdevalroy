import React, { useState } from "react";
import { View, Text, TextInput, Button } from "react-native";
import { PhoneAuthProvider, signInWithCredential, RecaptchaVerifier } from "firebase/auth";
import { auth } from "../firebase";

export default function PhoneAuthScreen() {
  const [phone, setPhone] = useState("");
  const [code, setCode] = useState("");
  const [verificationId, setVerificationId] = useState(null);

  const sendOTP = async () => {
    const verifier = new RecaptchaVerifier(
      "recaptcha-container",
      { size: "invisible" },
      auth
    );

    const provider = new PhoneAuthProvider(auth);
    const id = await provider.verifyPhoneNumber(phone, verifier);
    setVerificationId(id);

    alert("OTP Sent!");
  };

  const verifyCode = async () => {
    const credential = PhoneAuthProvider.credential(verificationId, code);
    await signInWithCredential(auth, credential);
    alert("Phone Verified!");
  };

  return (
    <View style={{ padding: 20 }}>
      <Text style={{ fontSize: 24 }}>Phone Login</Text>

      <View id="recaptcha-container" />

      <TextInput
        placeholder="+91 1234567890"
        style={{ borderWidth: 1, padding: 10, marginVertical: 10 }}
        onChangeText={setPhone}
      />

      <Button title="Send OTP" onPress={sendOTP} />

      <TextInput
        placeholder="Enter OTP"
        style={{ borderWidth: 1, padding: 10, marginVertical: 10 }}
        onChangeText={setCode}
      />

      <Button title="Verify OTP" onPress={verifyCode} />
    </View>
  );
}
