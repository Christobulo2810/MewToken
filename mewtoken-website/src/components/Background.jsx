import React from "react";
import { motion } from "framer-motion";

const gradients = [
  "linear-gradient(135deg, #4C1D95, #DB2777)", // Morado oscuro a rosa
  "linear-gradient(135deg, #6B21A8, #EC4899)", // Violeta a rosa neón
  "linear-gradient(135deg, #312E81, #A855F7)", // Azul oscuro a púrpura
];

const Background = () => {
  return (
    <motion.div
      className="absolute inset-0 w-full h-full"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 2 }}
    >
      {/* Animación de fondo en degradado */}
      <motion.div
        className="absolute inset-0 w-full h-full"
        animate={{
          backgroundImage: gradients,
          transition: {
            duration: 8,
            ease: "easeInOut",
            repeat: Infinity,
            repeatType: "reverse",
          },
        }}
      />
    </motion.div>
  );
};

export default Background;

