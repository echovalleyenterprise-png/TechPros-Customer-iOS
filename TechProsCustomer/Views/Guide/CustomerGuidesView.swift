import SwiftUI

struct CustomerGuidesView: View {
    @State private var selectedCategory: GuideCategory? = nil
    @State private var searchText = ""

    var filteredCategories: [GuideCategory] {
        if searchText.isEmpty { return GuideCategory.all }
        return GuideCategory.all.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.guides.contains { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Search bar built in via searchable
                ForEach(filteredCategories) { category in
                    Section {
                        ForEach(category.guides) { guide in
                            NavigationLink {
                                GuideDetailView(guide: guide)
                            } label: {
                                HStack(spacing: 12) {
                                    Text(category.icon)
                                        .font(.title2)
                                        .frame(width: 36)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(guide.title)
                                            .font(.subheadline).fontWeight(.medium)
                                            .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                        Text(guide.subtitle)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    } header: {
                        Text(category.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search guides…")
            .navigationTitle("Guides")
            .listStyle(.insetGrouped)
        }
    }
}

// MARK: - Guide Detail

struct GuideDetailView: View {
    let guide: Guide

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(guide.icon)
                        .font(.system(size: 44))
                    Text(guide.title)
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Text(guide.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Steps
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(guide.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.1, green: 0.5, blue: 1.0))
                                    .frame(width: 28, height: 28)
                                Text("\(index + 1)")
                                    .font(.caption).fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Text(step)
                                .font(.body)
                                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                .padding(.horizontal, 16)

                // Tip
                if let tip = guide.tip {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                        Text(tip)
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    }
                    .padding(16)
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(14)
                    .padding(.horizontal, 16)
                }

                // Still need help prompt
                VStack(spacing: 12) {
                    Text("Still having trouble?")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Text("Our AI assistant can walk you through it step by step.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color(red: 0.94, green: 0.97, blue: 1.0))
                .cornerRadius(16)
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 0.96, green: 0.97, blue: 0.99).ignoresSafeArea())
    }
}

// MARK: - Data Models

struct GuideCategory: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let guides: [Guide]

    static let all: [GuideCategory] = [
        GuideCategory(icon: "📺", name: "TVs", guides: [
            Guide(icon: "📺", title: "TV Won't Turn On", subtitle: "Power and remote troubleshooting",
                  steps: [
                    "Check that the TV power cord is firmly plugged into the outlet.",
                    "Try a different outlet or power strip.",
                    "Press the physical power button on the TV (not just the remote).",
                    "Remove the remote batteries, wait 30 seconds, and reinsert.",
                    "If still no power, unplug the TV for 60 seconds then plug back in.",
                    "Check if the standby light (usually red or amber) is on — if yes, the TV has power but isn't responding."
                  ],
                  tip: "Most 'dead TV' issues are solved by a 60-second unplug cycle."),
            Guide(icon: "📡", title: "No Signal or Black Screen", subtitle: "Fix HDMI and input issues",
                  steps: [
                    "Press 'Input' or 'Source' on your remote to check you're on the right input (HDMI 1, HDMI 2, etc.).",
                    "Unplug the HDMI cable from both ends, wait 10 seconds, and plug back in firmly.",
                    "Try a different HDMI port on the TV.",
                    "Try a different HDMI cable if you have one.",
                    "If using a cable box or game console, make sure it's powered on.",
                    "For streaming sticks (Roku, Fire Stick), try re-plugging it and waiting 30 seconds."
                  ],
                  tip: "HDMI 1 is usually the best port — some TVs have older HDMI 2 ports that don't support 4K."),
        ]),
        GuideCategory(icon: "📶", name: "WiFi & Internet", guides: [
            Guide(icon: "📶", title: "Device Won't Connect to WiFi", subtitle: "WiFi connection troubleshooting",
                  steps: [
                    "Make sure you're selecting the correct WiFi network (check for 2.4GHz vs 5GHz).",
                    "Double-check the password — it's case-sensitive.",
                    "Restart the device you're trying to connect.",
                    "Restart your WiFi router (unplug for 30 seconds, plug back in).",
                    "On the device, try 'Forget Network' and reconnect from scratch.",
                    "Move the device closer to the router to rule out signal strength issues."
                  ],
                  tip: "Smart home devices often only work on 2.4GHz networks. Look for a network ending in '2G' or '2.4G'."),
            Guide(icon: "🌐", title: "Internet Is Slow", subtitle: "Speed up your connection",
                  steps: [
                    "Run a speed test at fast.com to see your actual speeds.",
                    "Restart your router by unplugging it for 30 seconds.",
                    "Move your router to a central location in your home.",
                    "Reduce interference by keeping the router away from microwaves and cordless phones.",
                    "Connect devices by Ethernet cable when possible for faster speeds.",
                    "Contact your internet provider if speeds are consistently below what you pay for."
                  ],
                  tip: "WiFi speed drops significantly through walls and floors. A WiFi extender or mesh system can help in large homes."),
        ]),
        GuideCategory(icon: "🔔", name: "Doorbells & Cameras", guides: [
            Guide(icon: "🔔", title: "Video Doorbell Not Working", subtitle: "Ring, Nest, Arlo setup help",
                  steps: [
                    "Check the doorbell is getting power — the light ring should glow.",
                    "Open the doorbell app and check if the device shows as online.",
                    "Make sure your phone's WiFi is on the same network as the doorbell.",
                    "Try ringing the doorbell to test if you get a notification.",
                    "If offline, press and hold the setup button to restart it.",
                    "Check that the doorbell has strong WiFi signal — weak signal causes offline issues."
                  ],
                  tip: "Video doorbells need a solid WiFi signal. If yours is in a dead zone, consider a WiFi extender near the front door."),
            Guide(icon: "📷", title: "Security Camera Offline", subtitle: "Get your camera back online",
                  steps: [
                    "Open the camera app and check the device status.",
                    "Power cycle the camera: unplug it, wait 10 seconds, plug back in.",
                    "Verify your WiFi network is working on your phone.",
                    "Make sure the camera is within range of your router.",
                    "Check that the camera firmware is up to date in the app.",
                    "If still offline, try removing and re-adding the camera in the app."
                  ],
                  tip: "Outdoor cameras are prone to going offline after power outages. A UPS (battery backup) for your router prevents most outages."),
        ]),
        GuideCategory(icon: "🌡️", name: "Thermostats", guides: [
            Guide(icon: "🌡️", title: "Thermostat Has Blank Screen", subtitle: "Power and wiring checks",
                  steps: [
                    "Check if your thermostat uses batteries — try replacing them.",
                    "Look for a circuit breaker labeled 'HVAC' or 'Furnace' and make sure it's not tripped.",
                    "Check the furnace door — many systems won't power on if the furnace panel is open.",
                    "Make sure the C-wire (common wire) is securely connected on both the thermostat and furnace.",
                    "Try resetting the thermostat: remove from the wall plate for 30 seconds.",
                    "If wired correctly and still blank, the thermostat may need replacement."
                  ],
                  tip: "The C-wire provides consistent power to smart thermostats. If your old thermostat worked but the new one doesn't, a missing C-wire is often the cause."),
        ]),
        GuideCategory(icon: "🔊", name: "Sound", guides: [
            Guide(icon: "🔊", title: "No Sound from TV", subtitle: "Audio troubleshooting",
                  steps: [
                    "Make sure the TV isn't muted — press the mute button once.",
                    "Turn the volume up using the TV remote, not just the soundbar remote.",
                    "Check the TV audio settings: Settings → Sound → Sound Output → select TV Speakers or your soundbar.",
                    "If using HDMI ARC, make sure the cable is in the ARC-labeled port.",
                    "Try using the TV's built-in speakers first to confirm the TV itself works.",
                    "Power cycle the soundbar: turn it off, unplug for 30 seconds, plug back in."
                  ],
                  tip: "HDMI ARC requires the TV and soundbar to both be on and connected to the ARC port specifically — it doesn't work on all HDMI ports."),
        ]),
        GuideCategory(icon: "💡", name: "Smart Lights", guides: [
            Guide(icon: "💡", title: "Smart Lights Won't Respond", subtitle: "Fix Hue, Kasa, and smart bulbs",
                  steps: [
                    "Make sure the light switch for the bulb is ON — smart bulbs need constant power.",
                    "Close and reopen the app, then try controlling the light.",
                    "Check that your phone is on the same WiFi as the bulbs.",
                    "Restart the smart home hub (Hue Bridge, SmartThings, etc.) if you use one.",
                    "Try turning the physical switch off for 10 seconds, then back on.",
                    "If the bulb still won't respond, try a factory reset: rapidly switch it off/on 5 times."
                  ],
                  tip: "Never use a dimmer switch with smart bulbs — it cuts their power and causes connection issues. Use the app to dim instead."),
        ]),
    ]
}

struct Guide: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let steps: [String]
    var tip: String? = nil
}
