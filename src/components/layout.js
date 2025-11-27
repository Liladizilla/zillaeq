import React, { useState, useEffect } from "react";
import {
  Box,
  Drawer,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Typography,
  AppBar,
  Toolbar,
  IconButton,
  useTheme,
  useMediaQuery,
} from "@mui/material";
import { Home, Settings, Info, Menu } from "@mui/icons-material";
import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";

const drawerWidth = 240;

export default function Layout({ children }) {
  const theme = useTheme();
  const isDesktop = useMediaQuery(theme.breakpoints.up("md"));
  const [open, setOpen] = useState(isDesktop);
  const navigate = useNavigate();

  useEffect(() => {
    setOpen(isDesktop);
  }, [isDesktop]);

  const navItems = [
    { text: "Home", icon: <Home />, path: "/" },
    { text: "Settings", icon: <Settings />, path: "/settings" },
    { text: "About", icon: <Info />, path: "/about" },
  ];

  return (
    <Box
      sx={{
        display: "flex",
        height: "100vh",
        background: "radial-gradient(circle at top, #0d1b2a, #000814 70%)",
        color: "#e0f2ff",
        overflow: "hidden",
      }}
    >
      {/* ===== Sidebar ===== */}
      <Drawer
        variant={isDesktop ? "persistent" : "temporary"}
        open={open}
        onClose={() => setOpen(false)}
        ModalProps={{ keepMounted: true }}
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          "& .MuiDrawer-paper": {
            width: drawerWidth,
            boxSizing: "border-box",
            background:
              "linear-gradient(180deg, rgba(10,25,47,0.9) 0%, rgba(17,36,64,0.7) 100%)",
            backdropFilter: "blur(10px)",
            color: "#64ffda",
            borderRight: "1px solid rgba(100,255,218,0.1)",
            boxShadow: "0 0 25px rgba(100,255,218,0.1)",
          },
        }}
      >
        <Box sx={{ p: 2, textAlign: "center" }}>
          <Typography
            variant="h6"
            sx={{
              fontWeight: 700,
              color: "#64ffda",
              letterSpacing: 1,
              textShadow: "0 0 10px rgba(100,255,218,0.5)",
            }}
          >
            🎧 ZillaEQ
          </Typography>
        </Box>

        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <List>
            {navItems.map((item) => (
              <ListItemButton
                key={item.text}
                onClick={() => {
                  navigate(item.path);
                  if (!isDesktop) setOpen(false);
                }}
                sx={{
                  my: 1,
                  mx: 1,
                  borderRadius: 2,
                  transition: "0.3s",
                  "&:hover": {
                    background: "rgba(100,255,218,0.08)",
                    boxShadow: "0 0 10px rgba(100,255,218,0.3)",
                    transform: "translateY(-2px)",
                  },
                }}
              >
                <ListItemIcon sx={{ color: "#64ffda", minWidth: 40 }}>
                  {item.icon}
                </ListItemIcon>
                <ListItemText
                  primary={
                    <Typography
                      variant="body1"
                      sx={{ fontWeight: 600, color: "#e0f2ff" }}
                    >
                      {item.text}
                    </Typography>
                  }
                />
              </ListItemButton>
            ))}
          </List>
        </motion.div>
      </Drawer>

      {/* ===== Top Bar ===== */}
      <AppBar
        position="fixed"
        sx={{
          ml: open && isDesktop ? `${drawerWidth}px` : 0,
          width: open && isDesktop ? `calc(100% - ${drawerWidth}px)` : "100%",
          background:
            "linear-gradient(90deg, rgba(10,25,47,0.9), rgba(17,36,64,0.8))",
          backdropFilter: "blur(8px)",
          borderBottom: "1px solid rgba(100,255,218,0.1)",
          boxShadow: "0 2px 15px rgba(0,0,0,0.4)",
        }}
      >
        <Toolbar>
          <IconButton
            onClick={() => setOpen(!open)}
            color="inherit"
            edge="start"
            sx={{ mr: 2 }}
          >
            <Menu />
          </IconButton>
          <Typography
            variant="h6"
            sx={{
              fontWeight: 600,
              color: "#64ffda",
              textShadow: "0 0 8px rgba(100,255,218,0.5)",
            }}
          >
            Equalizer Dashboard
          </Typography>
        </Toolbar>

        {/* Animated waveform under the top bar */}
        <motion.div
          animate={{ opacity: [0.6, 1, 0.6] }}
          transition={{ duration: 2, repeat: Infinity }}
          style={{
            height: "3px",
            width: "100%",
            background:
              "repeating-linear-gradient(90deg, #64ffda, #00bcd4, #8a2be2)",
            boxShadow: "0 0 15px #64ffda",
          }}
        />
      </AppBar>

      {/* ===== Main Content ===== */}
      <Box
        component={motion.main}
        initial={{ opacity: 0, y: 15 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
        sx={{
          flexGrow: 1,
          p: 3,
          mt: 10,
          color: "#ccd6f6",
          overflowY: "auto",
          background:
            "linear-gradient(180deg, rgba(10,25,47,1) 0%, rgba(17,36,64,1) 100%)",
        }}
      >
        {children}
      </Box>
    </Box>
  );
}
