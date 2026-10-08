//
//  NutritionReportExtension.swift
//  NutritionReportExtension
//
//  One scene per context the app renders with DeviceActivityReport.
//

import DeviceActivity
import ExtensionKit
import SwiftUI
import Foundation

@main
struct NutritionReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        HookInsightScene()
        TodayScene()
        NutritionLabelScene()
        WeeklyGradeScene()
    }
}

// MARK: - Hook insight (onboarding)

struct HookInsightScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .init(ReportContexts.hookInsight)
    let content: (ReportSnapshot) -> HookInsightReportView = { HookInsightReportView(snapshot: $0) }

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ReportSnapshot {
        let state = SharedStore.shared.load()
        return await ReportComputer.compute(data: data, state: state, collectApps: false)
    }
}

// MARK: - Today (Kitchen card)

struct TodayScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .init(ReportContexts.today)
    let content: (ReportSnapshot) -> TodayReportView = { TodayReportView(snapshot: $0) }

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ReportSnapshot {
        let state = SharedStore.shared.load()
        return await ReportComputer.compute(data: data, state: state, collectApps: false)
    }
}

// MARK: - Nutrition label (Report tab)

struct NutritionLabelScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .init(ReportContexts.nutritionLabel)
    let content: (ReportSnapshot) -> NutritionLabelReportView = { NutritionLabelReportView(snapshot: $0) }

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ReportSnapshot {
        let state = SharedStore.shared.load()
        return await ReportComputer.compute(data: data, state: state, collectApps: true)
    }
}

// MARK: - Weekly grade (Report tab + Sunday screen)

struct WeeklyGradeScene: DeviceActivityReportScene {
    struct Configuration: Hashable {
        let snapshot: ReportSnapshot
        let grade: String
    }

    let context: DeviceActivityReport.Context = .init(ReportContexts.weeklyGrade)
    let content: (Configuration) -> WeeklyGradeReportView = { WeeklyGradeReportView(snapshot: $0.snapshot, grade: $0.grade) }

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Configuration {
        let state = SharedStore.shared.load()
        let snapshot = await ReportComputer.compute(data: data, state: state, collectApps: false)
        let grade = NutritionGrade.calculate(
            snapshot: snapshot,
            portionMinutes: state.portionMinutesForReport,
            windowMinutes: state.windowMinutesForReport
        )
        return Configuration(snapshot: snapshot, grade: grade)
    }
}
