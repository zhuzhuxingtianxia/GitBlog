# iOS开发之MetricKit性能监控

## 介绍
iOS 14 之后，Apple 推出了 MetricKit — 一个由系统统一收集性能指标并按日自动送达给应用的强大框架。不需要侵入式埋点，不需要长期后台运行，也不需要手动分析复杂的系统行为，MetricKit 能够帮助开发者在真实用户设备上捕获 CPU、内存、启动耗时、异常诊断等关键性能指标。


## 特点
* 自动收集：基于设备上的真实行为，系统会在后台定期收集性能数据。
* 每天或启动时上报：每次应用启动，系统会把前一天的性能指标通过回调送达。
* 极低侵入：性能统计由系统统一完成，不增加 CPU/内存负担，不影响用户体验。
* 结构标准：系统提供结构化的 MXMetricPayload，便于解析与分析。
* 隐私保护：Apple 会对数据进行匿名化和聚合处理，保护用户隐私。

## 步骤
1. 导入 MetricKit。
2. 注册 MetricKit 的订阅者。
3. 实现回调协议，接受 Metric 数据。
4. 逐项解析 Metric 数据。
5. 上传 Metric 数据到服务器（可选）。

## 使用代码
以下是一份应用 MetricKit 的模版代码。
```
import MetricKit
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MXMetricManager.shared.add(self)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        MXMetricManager.shared.remove(self)
    }
}

// MARK: - MXMetricManagerSubscriber，回调协议
extension AppDelegate: MXMetricManagerSubscriber {
    // MARK: 接收每日性能指标
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            handleMetrics(payload)
        }
    }

    // MARK: 接收诊断报告（崩溃、挂起等）
    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            handleDiagnostic(payload)
        }
    }

    // MARK: 处理每日性能指标
    func handleMetrics(_ payload: MXMetricPayload) {
        print("===== 开始处理性能指标 =====")
        // 时间范围
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let timeRange = "\(formatter.string(from: payload.timeStampBegin)) - \(formatter.string(from: payload.timeStampEnd))"
        print("指标时间范围: \(timeRange)")

        // CPU指标
        if let cpu = payload.cpuMetrics {
            let cpuTime = cpu.cumulativeCPUTime.value
            print("CPU总使用时间: \(String(format: "%.2f", cpuTime)) 秒")
        }

        // GPU指标
        if let gpu = payload.gpuMetrics {
            let gpuTime = gpu.cumulativeGPUTime.value
            print("GPU总使用时间: \(String(format: "%.2f", gpuTime)) 秒")
        }

        // 内存指标
        if let memory = payload.memoryMetrics {
            let avgMemory = memory.averageSuspendedMemory.averageMeasurement.value
            let peakMemory = memory.peakMemoryUsage.value
            print("平均挂起内存: \(String(format: "%.2f", avgMemory / 1024 / 1024)) MB")
            print("峰值内存使用: \(String(format: "%.2f", peakMemory / 1024 / 1024)) MB")
        }

        // 启动时间指标
        if let launch = payload.applicationLaunchMetrics {
            let histogram = launch.histogrammedTimeToFirstDraw
            print("启动时间分布: ")
            for bucket in histogram.bucketEnumerator {
                if let bucket = bucket as? MXHistogramBucket<UnitDuration> {
                    let start = String(format: "%.2f", bucket.bucketStart.value)
                    let end = String(format: "%.2f", bucket.bucketEnd.value)
                    print("范围: \(start)-\(end)秒, 次数: \(bucket.bucketCount)")
                }
            }
        }

        // 上传数据
        let jsonData = payload.jsonRepresentation()
        uploadToServer(jsonData)
    }

    // MARK: 处理诊断报告
    func handleDiagnostic(_ payload: MXDiagnosticPayload) {
        print("===== 开始处理诊断报告 =====")

        // 崩溃诊断
        if let crashes = payload.crashDiagnostics {
            print("崩溃次数: \(crashes.count)")
            for (index, crash) in crashes.enumerated() {
                print("崩溃 \(index + 1): ")
                print("应用版本: \(crash.metaData.applicationBuildVersion)")
                print("设备类型: \(crash.metaData.deviceType)")
                print("系统版本: \(crash.metaData.osVersion)")
                print("平台架构: \(crash.metaData.platformArchitecture)")
                print("调用栈: \(crash.callStackTree)")
            }
        }

        // CPU异常
        if let cpuExceptions = payload.cpuExceptionDiagnostics {
            print("CPU异常次数: \(cpuExceptions.count)")
            for (index, exception) in cpuExceptions.enumerated() {
                print("CPU异常 \(index + 1): ")
                print("总CPU时间: \(exception.totalCPUTime.value) 秒")
                print("调用栈: \(exception.callStackTree)")
            }
        }

        // 上传数据
        let jsonData = payload.jsonRepresentation()
        uploadToServer(jsonData)
    }

    // MARK: 上传数据到服务器
    func uploadToServer(_ json: Data) {
        guard !json.isEmpty else { return }
        // 上传数据，如URLSession上传
    }
}
```