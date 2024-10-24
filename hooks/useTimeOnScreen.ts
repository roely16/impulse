import { useState, useEffect } from "react";

const useTimeOnScreen = () => {
  const [startTime, setStartTime] = useState<number | null>(null);

  useEffect(() => {
    // Guardar el tiempo cuando se monta el componente
    const currentTime = Date.now();
    setStartTime(currentTime);

    return () => {
      // Cleanup opcional si necesitas hacer algo al desmontar el componente
    };
  }, []);

  const getTimeOnScreen = () => {
    if (!startTime) return 0; // Si por alguna razón no se ha iniciado el tiempo
    return (Date.now() - startTime) / 1000; // Retorna el tiempo en segundos
  };

  return getTimeOnScreen;
};

export default useTimeOnScreen;
