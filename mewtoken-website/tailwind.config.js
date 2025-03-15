/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,jsx,ts,tsx}"], // Asegura que Tailwind escanee los archivos
  theme: {
    extend: {
      colors: {
        "purple-400": "#a855f7",
        "pink-500": "#ec4899",
      },
    },
  },
  plugins: [],
};
