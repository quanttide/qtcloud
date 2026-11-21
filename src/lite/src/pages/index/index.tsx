import { View, Text } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import './index.scss'

type Feature = {
  name: string
  description: string
  url: string
  status: string
}

/** 功能列表：目前只有课程云 Lite 一个入口 */
const features: Feature[] = [
  {
    name: '课程云 Lite',
    description: '课程清单：通识课程与领域课程，标着上线状态',
    url: 'https://lite.course.cloud.quanttide.com/',
    status: '已上线',
  },
]

function openFeature(url: string) {
  if (process.env.TARO_ENV === 'h5') {
    window.open(url, '_blank')
    return
  }
  // 小程序不能直接跳外部域名：复制链接，提示浏览器打开
  Taro.setClipboardData({ data: url })
  Taro.showToast({ title: '链接已复制，浏览器打开', icon: 'none' })
}

export default function Index() {
  useLoad(() => {
    console.log('Page loaded.')
  })

  return (
    <View className='index'>
      <View className='head'>
        <Text className='title'>量潮云 Lite</Text>
        <Text className='subtitle'>功能列表</Text>
      </View>

      <View className='featureList'>
        {features.map(feature => (
          <View
            key={feature.name}
            className='featureItem'
            onClick={() => openFeature(feature.url)}
          >
            <View className='featureHead'>
              <Text className='featureName'>{feature.name}</Text>
              <Text className='featureStatus'>{feature.status}</Text>
            </View>
            <Text className='featureDesc'>{feature.description}</Text>
            <Text className='featureUrl'>{feature.url}</Text>
          </View>
        ))}
      </View>
    </View>
  )
}
