import React, { useState, useRef, useEffect } from 'react';
import { sha256 } from 'js-sha256';
import TimeSlider from './components/TimeSlider';
import DynamicBarChart from './components/DynamicBarChart';
import Clock from './components/Clock';

// 生产环境API配置
const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? window.location.origin 
  : 'http://localhost:5000';

function App() {
  // 登录状态，带过期时间
  const [authed, setAuthed] = useState(() => {
    const item = localStorage.getItem('bear_authed');
    if (!item) return false;
    try {
      const { ts } = JSON.parse(item);
      if (Date.now() - ts < 3600 * 1000) return true; // 1小时内
    } catch {}
    localStorage.removeItem('bear_authed');
    return false;
  });
  const [inputPwd, setInputPwd] = useState('');
  const [passwordHash, setPasswordHash] = useState<string | null>(null);

  // 实时数据
  const [realtimeData, setRealtimeData] = useState<any[][]>([]);
  const [realtimeActive, setRealtimeActive] = useState(false);
  // 历史数据
  const [allData, setAllData] = useState<{ [t: string]: any[][] }>({});
  const [timestamps, setTimestamps] = useState<string[]>([]);
  const [curIdx, setCurIdx] = useState(0);
  const [loading, setLoading] = useState(true);
  const [playing, setPlaying] = useState(false);
  const [error, setError] = useState('');
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const realtimeTimerRef = useRef<NodeJS.Timeout | null>(null);

  // 查询参数
  const [date, setDate] = useState('2025-07-18');
  const [start, setStart] = useState('09:15:00');
  const [end, setEnd] = useState('09:25:00');

  // 获取密码哈希
  useEffect(() => {
    const fetchPasswordHash = async () => {
      try {
        const response = await fetch(`${API_BASE_URL}/api/password_hash`);
        if (response.ok) {
          const data = await response.json();
          setPasswordHash(data.hash);
        }
      } catch (err) {
        console.error('获取密码信息失败:', err);
      }
    };

    fetchPasswordHash();
  }, []);

  // 时间格式化为HHMMSS
  const timeToHHMMSS = (t: string) => t.replace(/:/g, '');

  // 实时数据定时请求逻辑
  useEffect(() => {
    function isInRealtimePeriod() {
      const now = new Date();
      const h = now.getHours(), m = now.getMinutes(), s = now.getSeconds();
      const cur = h * 3600 + m * 60 + s;
      const startSec = 9 * 3600 + 15 * 60;
      const endSec = 9 * 3600 + 25 * 60;
      return cur >= startSec && cur <= endSec;
    }
    function fetchRealtime() {
      fetch(`${API_BASE_URL}/api/realtime_limit`)
        .then(res => res.json())
        .then(json => {
          if (json.info) setRealtimeData(json.info);
        })
        .catch(() => setRealtimeData([]));
    }
    // 页面加载时无论何时都请求一次
    fetchRealtime();
    if (isInRealtimePeriod()) {
      setRealtimeActive(true);
      realtimeTimerRef.current = setInterval(() => {
        fetchRealtime();
      }, 1000);
    } else {
      setRealtimeActive(false);
      setRealtimeData([]);
    }
    // 检查时间段变化
    const checkTimer = setInterval(() => {
      if (!isInRealtimePeriod()) {
        setRealtimeActive(false);
        if (realtimeTimerRef.current) clearInterval(realtimeTimerRef.current);
      } else if (!realtimeActive) {
        setRealtimeActive(true);
        fetchRealtime();
        realtimeTimerRef.current = setInterval(() => {
          fetchRealtime();
        }, 1000);
      }
    }, 1000);
    return () => {
      if (realtimeTimerRef.current) clearInterval(realtimeTimerRef.current);
      clearInterval(checkTimer);
    };
    // eslint-disable-next-line
  }, [realtimeActive]);

  // 历史数据查询逻辑
  const fetchData = (d: string, s: string, e: string) => {
    setLoading(true);
    setError('');
    fetch(`${API_BASE_URL}/api/bidding?date=${d}&start=${s}&end=${e}`)
      .then(res => res.json())
      .then(json => {
        if (json.error) {
          setError(json.error);
          setAllData({});
          setTimestamps([]);
        } else {
          setAllData(json.data || {});
          setTimestamps(json.timestamps || []);
          setCurIdx(0);
        }
        setLoading(false);
      })
      .catch((e) => {
        setError('接口请求失败，请检查后端服务是否启动');
        setAllData({});
        setTimestamps([]);
        setLoading(false);
        console.error('fetch error', e);
      });
  };

  useEffect(() => {
    fetchData(date, timeToHHMMSS(start), timeToHHMMSS(end));
    // eslint-disable-next-line
  }, []);

  // 历史数据回放控制
  const handlePlay = () => {
    if (playing) {
      setPlaying(false);
      if (timerRef.current) clearInterval(timerRef.current);
    } else {
      setPlaying(true);
      timerRef.current = setInterval(() => {
        setCurIdx(idx => {
          if (idx < timestamps.length - 1) {
            return idx + 1;
          } else {
            setPlaying(false);
            if (timerRef.current) clearInterval(timerRef.current);
            return idx;
          }
        });
      }, 500);
    }
  };

  const handleSliderChange = (val: number) => {
    setCurIdx(val);
    setPlaying(false);
    if (timerRef.current) clearInterval(timerRef.current);
  };

  const handleQuery = () => {
    setPlaying(false);
    if (timerRef.current) clearInterval(timerRef.current);
    fetchData(date, timeToHHMMSS(start), timeToHHMMSS(end));
  };

  const curData = timestamps.length > 0 ? (allData[timestamps[curIdx]] || []) : [];

  function handleLogin() {
    if (!passwordHash) {
      alert('密码系统未初始化，请稍后重试');
      return;
    }

    if (sha256(inputPwd) === passwordHash) {
      setAuthed(true);
      localStorage.setItem('bear_authed', JSON.stringify({ ts: Date.now() }));
    } else {
      alert('密码错误');
    }
  }

  // 登录遮罩页
  if (!authed) {
    return (
      <div style={{
        minHeight: '100vh', display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center', background: '#f7f9fa'
      }}>
        <div style={{
          background: '#fff', padding: 32, borderRadius: 12, boxShadow: '0 2px 16px #e0e6ed',
          minWidth: 320, textAlign: 'center'
        }}>
          <input
            type="password"
            placeholder="请输入密码"
            value={inputPwd}
            onChange={e => setInputPwd(e.target.value)}
            style={{padding: 8, width: '80%', marginBottom: 16, borderRadius: 6, border: '1px solid #ccc'}}
            onKeyDown={e => { if (e.key === 'Enter') handleLogin(); }}
          />
          <br />
          <button
            onClick={handleLogin}
            disabled={!passwordHash}
            style={{
              background: passwordHash ? '#409eff' : '#ccc', 
              color: '#fff', 
              border: 'none', 
              borderRadius: 6,
              padding: '8px 32px', 
              fontSize: 16, 
              fontWeight: 500, 
              cursor: passwordHash ? 'pointer' : 'not-allowed'
            }}
          >
            {passwordHash ? '登录' : '初始化中...'}
          </button>
        </div>
      </div>
    );
  }

  // 主页面
  return (
    <div className="App" style={{ padding: 32, background: '#f7f9fa', minHeight: '100vh', fontFamily: 'PingFang SC, Microsoft YaHei, Arial' }}>
      <div style={{ maxWidth: 1100, margin: '0 auto', background: '#fff', borderRadius: 12, boxShadow: '0 2px 16px #e0e6ed', padding: 32 }}>
        <h1 style={{textAlign:'center', fontSize: 32, fontWeight: 700, marginBottom: 24, letterSpacing: 2}}>竞价数据封单数据查看与回放</h1>
        <div style={{marginBottom: 32}}>
          {realtimeData && realtimeData.length > 0 ? (
            <DynamicBarChart data={realtimeData.filter(row => typeof row[1] === 'string' && !row[1].includes('ST'))} id="realtime-bar-chart" />
          ) : (
            <div style={{textAlign:'center',color:'#888',margin:'32px 0'}}>暂无实时竞价数据</div>
          )}
        </div>
        <hr style={{margin: '32px 0'}} />
        <div>
          {/* 历史数据区：柱状图在上，滑动条和播放按钮在下，查询条件和标题在最下方 */}
          <h1 style={{margin: '0 0 12px 0', fontSize: 28, color: '#222', textAlign: 'center', fontWeight: 700, letterSpacing: 2}}>历史回放</h1>
          <div style={{marginTop: 32}}>
            <DynamicBarChart data={curData} />
          </div>
          <div style={{textAlign:'center',marginBottom:8, fontSize: 16, fontWeight: 500}}>
            当前时间：{timestamps.length > 0 && curIdx >= 0 && curIdx < timestamps.length ? timestamps[curIdx] : '-'}
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 0, marginBottom: 8, flexWrap: 'nowrap' }}>
            <div style={{ flex: 1, minWidth: 0 }}>
              <TimeSlider
                min={0}
                max={timestamps.length - 1}
                value={curIdx}
                onChange={handleSliderChange}
              />
            </div>
            <button
              onClick={handlePlay}
              style={{
                background: playing ? '#f56c6c' : '#409eff',
                color: '#fff', 
                border: 'none', 
                borderRadius: 6,
                padding: '8px 18px',
                fontSize: 16,
                fontWeight: 500,
                cursor: 'pointer',
                boxShadow: playing ? '0 2px 8px #fbb' : '0 2px 8px #b3d8ff',
                transition: 'all 0.2s',
                marginLeft: 8,
                height: 36,
                display: 'inline-flex',
                alignItems: 'center',
                minWidth: 80,
                whiteSpace: 'nowrap',
                flexShrink: 0
              }}
            >
              {playing ? '暂停' : '播放'}
            </button>
          </div>
          {/* 查询按钮区自适应横向排列 */}
          <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 12, marginBottom: 24, flexWrap: 'nowrap' }}>
            <label>日期: <input type="date" value={date} onChange={e => setDate(e.target.value)} style={{ padding: 4, borderRadius: 4, border: '1px solid #ccc', minWidth: 90 }} /></label>
            <label>开始时间: <input type="time" value={start} onChange={e => setStart(e.target.value)} style={{ width: 90, padding: 4, borderRadius: 4, border: '1px solid #ccc' }} /></label>
            <label>结束时间: <input type="time" value={end} onChange={e => setEnd(e.target.value)} style={{ width: 90, padding: 4, borderRadius: 4, border: '1px solid #ccc' }} /></label>
            <button onClick={handleQuery} style={{ background: '#409eff', color: '#fff', border: 'none', borderRadius: 6, padding: '6px 16px', fontSize: 16, fontWeight: 500, cursor: 'pointer', minWidth: 70, whiteSpace: 'nowrap', flexShrink: 0 }}>查询</button>
          </div>
          {loading ? (
            <div style={{textAlign:'center',margin:'40px 0'}}>数据加载中...</div>
          ) : error ? (
            <div style={{textAlign:'center',margin:'40px 0', color:'#f56c6c', fontWeight:600}}>{error}</div>
          ) : timestamps.length === 0 ? (
            <div style={{textAlign:'center',margin:'40px 0', color:'#f56c6c', fontWeight:600}}>
              没有查询到数据，请检查日期和时间段是否正确！
            </div>
          ) : null}
        </div>
      </div>
    </div>
  );
}

export default App;