import React from "react";
import { motion } from "framer-motion";
import Background from "./components/Background";
import logo from "/logo.png"; // Asegúrate de que el logo esté en /public

const MewTokenWebsite = () => {
  return (
    <div className="relative min-h-screen flex flex-col items-center justify-center text-white overflow-hidden">
      {/* Fondo Animado */}
      <Background />

      {/* Contenido principal */}
      <motion.div
        className="relative z-10 flex flex-col items-center text-center p-4"
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1 }}
      >
        {/* Logo Redondeado */}
        <img
          src={logo}
          alt="MewToken Logo"
          className="w-32 h-32 rounded-full shadow-lg border-4 border-white mb-4"
        />

        {/* Texto de Bienvenida */}
        <h1 className="text-4xl font-extrabold">Bienvenido a MewToken</h1>
        <p className="text-lg mt-2 max-w-lg">
          La revolución en blockchain ha comenzado. Únete a la comunidad de MewToken y sé parte del futuro.
        </p>

        {/* Botones de Enlaces */}
        <div className="flex space-x-4 mt-6">
          <a href="https://www.tiktok.com" target="_blank" rel="noopener noreferrer">
            <motion.button
              whileHover={{ scale: 1.1 }}
              className="bg-black text-white px-4 py-2 rounded-lg shadow-md"
            >
              TikTok
            </motion.button>
          </a>
          <a href="https://twitter.com" target="_blank" rel="noopener noreferrer">
            <motion.button
              whileHover={{ scale: 1.1 }}
              className="bg-blue-500 text-white px-4 py-2 rounded-lg shadow-md"
            >
              X (Twitter)
            </motion.button>
          </a>
          <a href="https://metamask.io/" target="_blank" rel="noopener noreferrer">
            <motion.button
              whileHover={{ scale: 1.1 }}
              className="bg-yellow-500 text-white px-4 py-2 rounded-lg shadow-md"
            >
              Conectar MetaMask
            </motion.button>
          </a>
        </div>
      </motion.div>
    </div>
  );
};

export default MewTokenWebsite;
