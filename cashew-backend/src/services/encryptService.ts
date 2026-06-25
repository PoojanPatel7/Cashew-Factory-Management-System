import axios from 'axios';

const ENCRYPT_ENGINE_URL = process.env.ENCRYPT_ENGINE_URL || 'http://localhost:3000';
const ENCRYPT_API_KEY = process.env.ENCRYPT_API_KEY || 'default-api-key';

const engineClient = axios.create({
  baseURL: ENCRYPT_ENGINE_URL,
  headers: {
    'Authorization': `Bearer ${ENCRYPT_API_KEY}`,
    'Content-Type': 'application/json',
  },
});

export const encryptService = {
  async encrypt(plaintext: string): Promise<string> {
    try {
      if (!plaintext) return plaintext;
      // Mock encryption for local testing (Base64)
      return Buffer.from(plaintext).toString('base64');
    } catch (error) {
      console.error('Encryption failed:', error);
      throw new Error('Encrypt Engine Error');
    }
  },

  async decrypt(ciphertext: string): Promise<string> {
    try {
      if (!ciphertext) return ciphertext;
      // Mock decryption for local testing (Base64)
      return Buffer.from(ciphertext, 'base64').toString('utf-8');
    } catch (error) {
      console.error('Decryption failed:', error);
      throw new Error('Decrypt Engine Error');
    }
  }
};
