import './App.css'

const clouds: {
  name: string
  description: string
  url?: string
  live: boolean
}[] = [
  {
    name: '议事云',
    description: '决议管理，角色议事',
    url: 'https://delib.cloud.quanttide.com',
    live: true,
  },
  {
    name: '数据云',
    description: '数据工程平台',
    url: 'https://data.cloud.quanttide.com',
    live: true,
  },
  { name: '知识云', description: '语义中枢，本体建模', live: false },
  { name: '写作云', description: '叙事秩序引擎', live: false },
  { name: '执行云', description: '消除混乱，拿走空瓶子', live: false },
  { name: '沟通云', description: '价值传播与责任', live: false },
  { name: '智能体云', description: '上下文的具身化', live: false },
  { name: '客服云', description: '无人值守与信任', live: false },
  { name: '资产云', description: '数字资产治理', live: false },
]

const workspace = {
  name: '量潮云工作台',
  description: 'Cowork 形态：自然语言派活，各云作为领域专家被任务调度，交付可验收成果',
  url: 'https://cowork.cloud.quanttide.com',
}

export default function App() {
  return (
    <main className="app">
      <section className="hero">
        <h1>量潮云</h1>
        <p className="tagline">帮助人类消除人机协作摩擦的第二大脑</p>
        <p className="intro">
          各云各回答一个领域内的摩擦：从想法到落地之间的摩擦点，把认知负担卸下来。
        </p>
      </section>
      <section className="clouds">
        <h2>产品矩阵</h2>
        <div className="cloud-grid">
          <a key={workspace.url} className="cloud-card workspace" href={workspace.url}>
            <div className="card-head">
              <h3>{workspace.name}</h3>
              <span className="status live">入口</span>
            </div>
            <p className="description">{workspace.description}</p>
          </a>
          {clouds.map((cloud) => {
            const card = (
              <>
                <div className="card-head">
                  <h3>{cloud.name}</h3>
                  <span className={cloud.live ? 'status live' : 'status planned'}>
                    {cloud.live ? '已上线' : '规划中'}
                  </span>
                </div>
                <p className="description">{cloud.description}</p>
              </>
            )
            return cloud.live ? (
              <a key={cloud.name} className="cloud-card" href={cloud.url}>
                {card}
              </a>
            ) : (
              <div key={cloud.name} className="cloud-card disabled">
                {card}
              </div>
            )
          })}
        </div>
      </section>
    </main>
  )
}
