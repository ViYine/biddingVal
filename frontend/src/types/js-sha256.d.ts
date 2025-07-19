declare module 'js-sha256' {
  export function sha256(message: string): string;
  export function sha224(message: string): string;
  export function sha256hmac(key: string, message: string): string;
  export function sha224hmac(key: string, message: string): string;
} 