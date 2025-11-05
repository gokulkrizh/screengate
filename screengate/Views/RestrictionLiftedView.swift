//
//  RestrictionLiftedView.swift
//  screengate
//
//  Created by Gokul on 2025/11/05.
//

import SwiftUI
import Combine

struct RestrictionLiftedView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animationScale: CGFloat = 0.8
    @State private var animationOpacity: Double = 0
    @State private var breakTimer: Int = 300 // 5 minutes in seconds
    @State private var timerActive: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Success Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .scaleEffect(animationScale)
                    .opacity(animationOpacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            animationScale = 1.0
                            animationOpacity = 1.0
                        }
                    }

                // Title
                Text("Restrictions Lifted!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                // Description
                Text("Take a mindful break and enjoy your digital freedom. Remember to set new restrictions when you're ready to focus again.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Break Timer
                VStack(spacing: 10) {
                    Text("Break Timer")
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack(spacing: 15) {
                        VStack {
                            Text("\(breakTimer / 60)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                            Text("Minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text(":")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.secondary)

                        VStack {
                            Text(String(format: "%02d", breakTimer % 60))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                            Text("Seconds")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: {
                        timerActive.toggle()
                    }) {
                        Text(timerActive ? "Pause Timer" : "Start Timer")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(timerActive ? Color.orange : Color.green)
                            .cornerRadius(20)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    if timerActive && breakTimer > 0 {
                        breakTimer -= 1
                    }
                }

                Spacer()

                // Tips Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Quick Tips:")
                        .font(.headline)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 20)

                            Text("Use this break to stretch, hydrate, or rest your eyes")
                                .font(.subheadline)
                        }

                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: "target")
                                .foregroundColor(.blue)
                                .frame(width: 20)

                            Text("Set a timer for your break to stay mindful")
                                .font(.subheadline)
                        }

                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.orange)
                                .frame(width: 20)

                            Text("You can always set new restrictions when ready")
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()

                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Back to App")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        // TODO: Navigate to add new restrictions
                        dismiss()
                    }) {
                        Text("Set New Restrictions")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Break Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RestrictionLiftedView_Previews: PreviewProvider {
    static var previews: some View {
        RestrictionLiftedView()
    }
}