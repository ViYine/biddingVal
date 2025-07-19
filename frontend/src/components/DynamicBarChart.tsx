import React from 'react';
import { Flipper, Flipped } from 'react-flip-toolkit';

interface BarData {
  name: string;
  amount: number;
  inc: number;
  sector: string;
  bidAmount?: number;
  bidTurnover?: number;
}

interface DynamicBarChartProps {
  data: any[][];
  id?: string;
}

function formatAmountYi(amount: any): string {
  if (amount === null || amount === undefined || amount === '' || isNaN(Number(amount))) return '-';
  const n = Number(amount);
  return n ? (n / 1e8).toFixed(2) + '亿' : '0.00亿';
}

const DynamicBarChart: React.FC<DynamicBarChartProps> = ({ data, id }) => {
  const bars: BarData[] = data
    .map(row => ({
      name: row[1],
      amount: row[4],
      inc: row[5],
      sector: row[11],
      bidAmount: row[10],
      bidTurnover: row[7],
    }))
    .sort((a, b) => Number(b.amount) - Number(a.amount))
    .slice(0, 20);

  const maxAmount = bars[0]?.amount || 1;
  const flipKey = bars.map(b => b.name).join(',') + bars.map(b => b.amount).join(',');

  return (
    <div id={id} style={{ width: '100%', margin: '30px 0', marginTop: 40 }}>
      {/* @ts-ignore */}
      <Flipper flipKey={flipKey} spring="veryGentle">
        <div style={{ display: 'flex', alignItems: 'flex-end', height: 300, borderLeft: '1px solid #ccc', borderBottom: '1px solid #ccc', padding: '0 20px', background: '#fafdff', borderRadius: 8 }}>
          {bars.map((bar, idx) => {
            const incNum = Number(bar.inc);
            let valueColor = '#409eff';
            let barColor = '#409eff';
            let nameColor = '#222';
            if (!isNaN(incNum)) {
              if (incNum > 0) {
                valueColor = '#f56c6c';
                barColor = '#f56c6c';
              } else if (incNum < 0) {
                valueColor = '#1ca01c';
                barColor = '#1ca01c';
                nameColor = '#1ca01c';
              }
            }
            // 前3名柱体为黄色
            if (idx < 3) {
              barColor = '#FFD700';
            }
            return (
              // @ts-ignore
              <Flipped key={bar.name} flipId={bar.name}>
                <div style={{ width: 36, margin: '0 8px', display: 'flex', flexDirection: 'column', alignItems: 'center', position: 'relative' }}>
                  {/* 排名编号在最上方 */}
                  <div style={{ position: 'absolute', top: -95, left: '50%', transform: 'translateX(-50%)', color: '#409eff', fontWeight: 700, fontSize: 18 }}>{idx + 1}</div>
                  {/* 板块竖向显示在编号下方 */}
                  <div style={{ position: 'absolute', top: -70, left: '50%', transform: 'translateX(-50%)', writingMode: 'vertical-rl', color: '#888', fontSize: 12, maxHeight: 60, overflow: 'hidden', whiteSpace: 'nowrap', textOverflow: 'ellipsis' }}>{bar.sector}</div>
                  {/* 柱体 */}
                  <div
                    style={{
                      width: 28,
                      height: Math.max(10, Number(bar.amount) / Number(maxAmount) * 120),
                      background: barColor,
                      borderRadius: 6,
                      position: 'relative',
                      marginBottom: 4,
                      display: 'flex',
                      alignItems: 'flex-end',
                      justifyContent: 'center',
                      boxShadow: '0 2px 8px #e0e6ed',
                      transition: 'height 0.5s',
                    }}
                    title={`排名${idx + 1}  ${bar.name}\n封单额: ${formatAmountYi(bar.amount)}\n竞价涨幅: ${bar.inc}%\n开盘金额: ${formatAmountYi(bar.bidAmount)}\n竞价换手: ${bar.bidTurnover}%\n板块: ${bar.sector}`}
                  >
                    {/* 编号已移至上方，不再显示在柱体上 */}
                  </div>
                  {/* x轴下方文字 */}
                  <div style={{ textAlign: 'center', fontSize: 13, color: '#222', lineHeight: 1.3, width: 60, wordBreak: 'break-all', marginTop: 2 }}>
                    <div style={{ fontWeight: 600, color: nameColor, writingMode: 'vertical-rl', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', height: 60, margin: '0 auto' }}>{bar.name}</div>
                    <div style={{ color: valueColor, fontSize: 13 }}>{formatAmountYi(bar.amount)}</div>
                    <div style={{ color: valueColor, fontSize: 13 }}>{bar.inc}%</div>
                    <div style={{ color: '#000', fontSize: 12 }}>{formatAmountYi(bar.bidAmount)}</div>
                    <div style={{ color: '#000', fontSize: 12 }}>{bar.bidTurnover}%</div>
                  </div>
                </div>
              </Flipped>
            );
          })}
        </div>
      </Flipper>
    </div>
  );
};

export default DynamicBarChart; 