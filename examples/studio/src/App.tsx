import { useEffect, useMemo, useRef, useState } from 'react'
import './App.css'
import type { Task } from './types'
import { seedWorkspace } from './data'

const STORAGE_KEY = 'qtcloud-studio-demo-v2'

function loadTasks(): Task[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw) return JSON.parse(raw) as Task[]
  } catch {
    // 数据损坏则重新播种
  }
  return seedWorkspace.tasks
}

// 分层：level(t) = max(level(deps)) + 1（全景 DAG 总览用）
function levels(tasks: Task[]): Task[][] {
  const byId = new Map(tasks.map((t) => [t.id, t]))
  const memo = new Map<string, number>()
  const levelOf = (id: string): number => {
    const hit = memo.get(id)
    if (hit !== undefined) return hit
    const t = byId.get(id)!
    const l = t.dependsOn.length ? Math.max(...t.dependsOn.map(levelOf)) + 1 : 0
    memo.set(id, l)
    return l
  }
  tasks.forEach((t) => levelOf(t.id))
  const cols: (Task[] | undefined)[] = []
  for (const t of tasks) {
    const l = memo.get(t.id)!
    ;(cols[l] ??= []).push(t)
  }
  return cols.filter((c): c is Task[] => Boolean(c))
}

function depsLabel(t: Task, byId: Map<string, Task>): string {
  if (t.dependsOn.length === 0) return '无'
  return t.dependsOn.map((d) => byId.get(d)?.name ?? d).join('、')
}

export default function App() {
  const [tasks, setTasks] = useState<Task[]>(loadTasks)
  const [toast, setToast] = useState<string | null>(null)
  const [rejecting, setRejecting] = useState<string | null>(null)
  const [rejectNote, setRejectNote] = useState('')
  const [intent, setIntent] = useState('')
  const [dispatching, setDispatching] = useState(false)
  const [showDag, setShowDag] = useState(false)
  const [pulseId, setPulseId] = useState<string | null>(null)
  const timer = useRef<number | undefined>(undefined)

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(tasks))
  }, [tasks])

  useEffect(() => () => window.clearTimeout(timer.current), [])

  const say = (msg: string) => {
    setToast(msg)
    window.clearTimeout(timer.current)
    timer.current = window.setTimeout(() => setToast(null), 2400)
  }

  const byId = useMemo(() => new Map(tasks.map((t) => [t.id, t])), [tasks])

  // 就绪 = 待办且上游全部验收通过。DAG 在这里第一次有了调度语义。
  const isReady = (t: Task) =>
    t.status === '待办' && t.dependsOn.every((d) => byId.get(d)?.status === '完成')

  const awaiting = tasks.filter((t) => t.status === '待验收')
  const running = tasks.filter((t) => t.status === '执行中')
  const ready = tasks.filter(isReady)
  const done = tasks.filter((t) => t.status === '完成')
  const allDone = tasks.length > 0 && done.length === tasks.length

  const patch = (id: string, p: Partial<Task>) =>
    setTasks((cur) => cur.map((t) => (t.id === id ? { ...t, ...p } : t)))

  const start = (t: Task) => {
    patch(t.id, { status: '执行中' })
    say(`已开始：${t.name}`)
  }

  const submit = (t: Task) => {
    if (!(t.deliverable ?? '').trim()) {
      say('先填写交付物说明，再提交验收')
      return
    }
    patch(t.id, { status: '待验收' })
    say(`已提交验收：${t.name}`)
  }

  const approve = (t: Task) => {
    patch(t.id, { status: '完成' })
    say(`已验收 ✓ ${t.name}`)
  }

  const confirmReject = (t: Task) => {
    patch(t.id, {
      status: '执行中',
      review: rejectNote.trim() || '未通过，请修改后重新提交',
    })
    setRejecting(null)
    setRejectNote('')
    say(`已驳回：${t.name}`)
  }

  // 派活：说要什么，系统拆解。demo 为模拟拆解（真实实现由协作目录 + LLM 承担）。
  const dispatch = () => {
    const text = intent.trim()
    if (!text || dispatching) return
    setDispatching(true)
    window.setTimeout(() => {
      const id = `t${Date.now()}`
      setTasks((cur) => [
        ...cur,
        { id, name: text, executor: '用户', status: '待办', dependsOn: [] },
      ])
      setIntent('')
      setDispatching(false)
      setPulseId(id)
      say('已派活 · 拆解为 1 步')
      window.setTimeout(() => setPulseId(null), 1600)
    }, 700)
  }

  const reset = () => {
    localStorage.removeItem(STORAGE_KEY)
    setTasks(seedWorkspace.tasks)
    say('已重置为初始案例')
  }

  return (
    <main className="app">
      <header className="head">
        <h1>量潮云工作台</h1>
        <p className="ws-name">{seedWorkspace.name}</p>
        <p className="chips">
          <span className="chip">目标 {seedWorkspace.context.goal}</span>
          <span className="chip">边界 {seedWorkspace.context.boundary}</span>
        </p>
      </header>

      <section className="dispatch">
        <input
          value={intent}
          placeholder="说要什么，比如：把修订草案发给法务复核"
          onChange={(e) => setIntent(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && dispatch()}
          disabled={dispatching}
        />
        <button className="primary" onClick={dispatch} disabled={dispatching || !intent.trim()}>
          {dispatching ? '拆解中…' : '派活'}
        </button>
      </section>

      {allDone && (
        <section className="banner">
          🎉 工作流交付完成——「{seedWorkspace.name}」全部任务验收通过
        </section>
      )}

      <section className="zone">
        <h2>
          等你拍板
          {awaiting.length > 0 && <span className="count hot">{awaiting.length}</span>}
        </h2>
        {awaiting.length === 0 ? (
          <p className="empty">没有等你拍板的事 ✓</p>
        ) : (
          awaiting.map((t) => (
            <article key={t.id} className="card verdict-card">
              <h3>{t.name}</h3>
              <p className="meta">
                执行者 {t.executor} · 上游 {depsLabel(t, byId)}
              </p>
              <blockquote className="deliverable">{t.deliverable}</blockquote>
              {rejecting === t.id ? (
                <div className="reject-box">
                  <input
                    autoFocus
                    placeholder="驳回意见（回传给执行者）"
                    value={rejectNote}
                    onChange={(e) => setRejectNote(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && confirmReject(t)}
                  />
                  <button className="primary" onClick={() => confirmReject(t)}>
                    确认驳回
                  </button>
                  <button onClick={() => setRejecting(null)}>取消</button>
                </div>
              ) : (
                <div className="row">
                  <button className="approve" onClick={() => approve(t)}>
                    通过 ✓
                  </button>
                  <button
                    onClick={() => {
                      setRejecting(t.id)
                      setRejectNote('')
                    }}
                  >
                    驳回
                  </button>
                </div>
              )}
            </article>
          ))
        )}
      </section>

      <section className="zone">
        <h2>
          现在可动
          {ready.length + running.length > 0 && (
            <span className="count">{ready.length + running.length}</span>
          )}
        </h2>
        {ready.length + running.length === 0 ? (
          <p className="empty">暂无可推进的任务——派个活，或等云交付</p>
        ) : (
          [...running, ...ready].map((t) =>
            t.status === '执行中' ? (
              <article key={t.id} className="card">
                <h3>{t.name}</h3>
                <p className="meta">
                  执行中 · {t.executor}
                  {t.review ? ` · 驳回意见：${t.review}` : ''}
                </p>
                <textarea
                  placeholder="交付物说明"
                  value={t.deliverable ?? ''}
                  onChange={(e) => patch(t.id, { deliverable: e.target.value })}
                />
                <div className="row">
                  <button className="primary" onClick={() => submit(t)}>
                    提交验收
                  </button>
                </div>
              </article>
            ) : (
              <article key={t.id} className={`card row-card${pulseId === t.id ? ' pulse' : ''}`}>
                <div>
                  <h3>{t.name}</h3>
                  <p className="meta">
                    就绪 · {t.executor} · 上游 {depsLabel(t, byId)}
                  </p>
                </div>
                <button className="primary" onClick={() => start(t)}>
                  开始执行
                </button>
              </article>
            ),
          )
        )}
      </section>

      <section className="zone">
        <h2 className="dag-head">
          <button className="link" onClick={() => setShowDag((v) => !v)}>
            {showDag ? '▾' : '▸'} 全景 DAG
          </button>
          <span className="dag-progress">
            完成 {done.length} / {tasks.length}
          </span>
          <button className="link reset" onClick={reset}>
            重置
          </button>
        </h2>
        {showDag && (
          <div className="dag">
            {levels(tasks).map((col, i) => (
              <div key={i} className="col">
                {col.map((t) => (
                  <div key={t.id} className={`dag-card st-${t.status}`}>
                    <h4>{t.name}</h4>
                    <p className="meta">
                      {t.executor} · {t.status}
                    </p>
                    {t.dependsOn.length > 0 && (
                      <p className="deps-note">
                        ← {t.dependsOn.map((d) => byId.get(d)?.name).join('、')}
                      </p>
                    )}
                  </div>
                ))}
              </div>
            ))}
          </div>
        )}
      </section>

      {toast && <div className="toast">{toast}</div>}

      <footer className="foot">
        CoWork 模型原型 · 概念契约见 <code>src/types.ts</code> · 数据存于浏览器本地
      </footer>
    </main>
  )
}
