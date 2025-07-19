import React, { useEffect, useState } from 'react';

const weekMap = ['日', '一', '二', '三', '四', '五', '六'];

const Clock: React.FC = () => {
  const [now, setNow] = useState(new Date());
  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);
  const pad = (n: number) => n.toString().padStart(2, '0');
  const year = now.getFullYear();
  const month = pad(now.getMonth() + 1);
  const day = pad(now.getDate());
  const week = weekMap[now.getDay()];
  const hour = pad(now.getHours());
  const min = pad(now.getMinutes());
  const sec = pad(now.getSeconds());
  return (
    <div style={{fontSize: 22, fontWeight: 600, textAlign: 'center', marginBottom: 12}}>
      {year}-{month}-{day} 星期{week} {hour}:{min}:{sec}
    </div>
  );
};
export default Clock;