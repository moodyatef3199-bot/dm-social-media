/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: '#0089cc',
          dark: '#006fa6',
          darker: '#004d7a',
          light: '#e6f5fb',
          lighter: '#f0f9fe',
        },
        accent: {
          DEFAULT: '#ff7a00',
          dark: '#e06600',
          light: '#fff3e6',
        },
      },
      fontFamily: { cairo: ['Cairo', 'sans-serif'] },
    },
  },
  plugins: [],
}
