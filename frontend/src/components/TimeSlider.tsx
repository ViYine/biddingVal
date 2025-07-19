import React from 'react';

interface TimeSliderProps {
  min: number;
  max: number;
  value: number;
  onChange: (val: number) => void;
}

// 时间格式化函数
function formatTime(sec: number) {
  const h = Math.floor(sec / 3600).toString().padStart(2, '0');
  const m = Math.floor((sec % 3600) / 60).toString().padStart(2, '0');
  const s = (sec % 60).toString().padStart(2, '0');
  return `${h}:${m}:${s}`;
}

const TimeSlider: React.FC<TimeSliderProps> = ({ min, max, value, onChange }) => {
  // 只显示起止刻度
  return (
    <div style={{ margin: '20px 0', width: 600, maxWidth: '100%' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
        <span style={{ color: '#888', fontSize: 14 }}>{formatTime(min)}</span>
        <span style={{ color: '#888', fontSize: 14 }}>{formatTime(max)}</span>
      </div>
      <input
        type="range"
        min={min}
        max={max}
        value={value}
        onChange={e => onChange(Number(e.target.value))}
        step={1}
        style={{ width: '100%', accentColor: '#409eff', height: 6, borderRadius: 4 }}
      />
      {/* <div style={{ textAlign: 'center', marginTop: 8, fontWeight: 500, color: '#222', fontSize: 16 }}>
        当前时间：<span style={{ color: '#409eff' }}>{formatTime(value)}</span>
      </div> */}
    </div>
  );
};

export default TimeSlider; 