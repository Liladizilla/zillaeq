// src/theme.js
import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    mode: 'dark',
    primary: { main: '#6366F1' }, // violet-indigo
    secondary: { main: '#14B8A6' }, // teal
    background: { default: '#0F172A', paper: '#1E293B' },
    text: { primary: '#E2E8F0', secondary: '#94A3B8' },
  },
  typography: {
    fontFamily: '"Inter", "Poppins", "Roboto", sans-serif',
    h1: { fontWeight: 700, fontSize: '2.5rem' },
    h2: { fontWeight: 600, fontSize: '1.8rem' },
    body1: { fontSize: '1rem' },
  },
  shape: {
    borderRadius: 16,
  },
  shadows: Array(25).fill('0px 4px 20px rgba(0,0,0,0.2)'),
});

export default theme;
