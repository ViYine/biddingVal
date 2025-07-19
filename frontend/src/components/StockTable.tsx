import React from 'react';

function formatAmount(amount: any): string {
  if (amount === null || amount === undefined || amount === '') return '-';
  const n = Number(amount);
  if (isNaN(n)) return amount;
  if (n >= 1e8) {
    return (n / 1e8).toFixed(2) + '亿';
  } else if (n >= 1e4) {
    return (n / 1e4).toFixed(2) + '万';
  } else {
    return n + '元';
  }
}

// 合并后的表头
const columns = [
  '代码/名称', '现价', '涨幅', '涨停封单额', '开盘涨幅', '竞价净额', '竞价换手', '竞价成交额', '开盘金额', '板块', '实际流通值', '主力净', '主力买', '主力卖', '连板说明'
];
// 原始数据金额字段下标
const amountIndexes = [4, 6, 8, 9, 10, 12, 13, 14];
// 原始数据涨幅字段下标
const updownIndexes = [3, 5];

interface StockTableProps {
  data: any[][];
}

const StockTable: React.FC<StockTableProps> = ({ data }) => {
  return (
    <div style={{ overflowX: 'auto', borderRadius: 10, boxShadow: '0 2px 8px #e0e6ed', margin: '24px 0' }}>
      <table style={{ borderCollapse: 'separate', borderSpacing: 0, width: '100%', borderRadius: 10, overflow: 'hidden', background: '#fff', tableLayout: 'fixed' }}>
        <colgroup>
          <col style={{ width: '120px' }} />
          <col style={{ width: '70px' }} />
          <col style={{ width: '70px' }} />
          <col style={{ width: '110px' }} />
          <col style={{ width: '70px' }} />
          <col style={{ width: '90px' }} />
          <col style={{ width: '70px' }} />
          <col style={{ width: '110px' }} />
          <col style={{ width: '110px' }} />
          <col style={{ width: '120px' }} />
          <col style={{ width: '110px' }} />
          <col style={{ width: '90px' }} />
          <col style={{ width: '90px' }} />
          <col style={{ width: '90px' }} />
          <col style={{ width: '90px' }} />
        </colgroup>
        <thead>
          <tr>
            {columns.map((col, idx) => (
              <th key={col} style={{ borderBottom: '2px solid #e6e6e6', padding: '10px 8px', background: '#f5f7fa', color: '#333', fontWeight: 600, whiteSpace: 'nowrap', fontSize: 15 }}>{col}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, i) => (
            <tr key={i} style={{ background: i % 2 === 0 ? '#fafbfc' : '#fff', transition: 'background 0.2s' }}
              onMouseOver={e => (e.currentTarget.style.background = '#e6f7ff')}
              onMouseOut={e => (e.currentTarget.style.background = i % 2 === 0 ? '#fafbfc' : '#fff')}
            >
              {/* 代码/名称合并列 */}
              <td style={{ borderBottom: '1px solid #f0f0f0', padding: '8px', textAlign: 'center', fontWeight: 600, color: '#222', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', borderRight: '1px solid #f0f0f0', fontSize: 15 }}>
                <span title={row[0] + '/' + row[1]}>{row[0]}/{row[1]}</span>
              </td>
              {/* 其余字段严格对应原始数据顺序 row[2] ~ row[15] */}
              {row.slice(2).map((cell, j) => {
                // j+2 是原始数据的下标
                let color = '#222';
                if (updownIndexes.includes(j + 2)) {
                  const v = Number(cell);
                  if (!isNaN(v)) {
                    if (v > 0) color = '#f56c6c';
                    else if (v < 0) color = '#1ca01c';
                  }
                }
                // 金额字段
                let content = amountIndexes.includes(j + 2) && typeof cell !== 'string' ? formatAmount(cell) : cell;
                if (amountIndexes.includes(j + 2) && [4, 8, 9, 10].includes(j + 2)) {
                  // 这些金额字段也根据涨幅变色，涨幅用 row[3]
                  const v = Number(row[3]);
                  if (!isNaN(v)) {
                    if (v > 0) color = '#f56c6c';
                    else if (v < 0) color = '#1ca01c';
        }
                }
    return (
                  <td key={j + 1} style={{ borderBottom: '1px solid #f0f0f0', padding: '8px', textAlign: 'center', color, fontWeight: updownIndexes.includes(j + 2) ? 600 : 400, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', borderRight: '1px solid #f0f0f0', fontSize: 15 }}>
                    <span title={String(content)}>{content === '' || content === null ? '-' : content}</span>
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
      </table>
        </div>
    );
};

export default StockTable;