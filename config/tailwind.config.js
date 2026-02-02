/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/views/**/*.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        gray: {
          50: "#fff9f5",
        },
        stone: {
          50: "#fff9f5",
        },
      },
    },
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: [
      {
        light: {
          "color-scheme": "light",
          "base-100": "#ffffff",
          "base-200": "#f8f8f8",
          "base-300": "#eeeeee",
          "base-content": "#18181b",
          "primary": "#4d179a",
          "primary-content": "#ffffff",
          "primary-focus": "#3a1173",
          "secondary": "#4f46e5",
          "secondary-content": "#ffffff",
          "secondary-focus": "#3730a3",
          "accent": "#0b1e59",
          "accent-content": "#ffffff",
          "accent-focus": "#081435",
          "neutral": "#18181b",
          "neutral-content": "#ffffff",
          "info": "#00bafe",
          "info-content": "#0b3954",
          "success": "#00d390",
          "success-content": "#004c39",
          "warning": "#fcb700",
          "warning-content": "#793205",
          "error": "#dc2626",
          "error-content": "#ffffff",
        },
      },
    ],
  },
};
