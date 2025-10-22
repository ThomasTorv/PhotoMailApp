import SwiftUI
import MessageUI
import UIKit

struct ContentView: View {
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .camera
    @State private var showSourceOptions = false
    @State private var showMail = false
    @State private var mailUnavailableAlert = false
    @State private var imageSourceUnavailableAlert = false

    private let defaultRecipients = ["shipments@yourcompany.com"]
    private let defaultSubject = "Outbound shipment photo"
    private let defaultBody = "Photo attached."

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)).frame(height: 260)
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding()
                    } else {
                        Text("No photo yet").foregroundColor(.secondary)
                    }
                }
                HStack {
                    Button {
                        handleAddPhotoTapped()
                    } label: {
                        Label(addPhotoButtonLabel, systemImage: addPhotoButtonSystemImage)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        guard image != nil else { return }
                        if MFMailComposeViewController.canSendMail() {
                            showMail = true
                        } else {
                            mailUnavailableAlert = true
                        }
                    } label: {
                        Label("Email Photo", systemImage: "envelope.fill")
                    }
                    .buttonStyle(.bordered)
                    .disabled(image == nil)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Photo → Email")
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: imagePickerSource) { picked in
                image = picked
            }
        }
        .confirmationDialog("Choose a photo source", isPresented: $showSourceOptions, titleVisibility: .visible) {
            let sources = availableImageSources
            ForEach(sources) { source in
                Button(source.label) {
                    presentImagePicker(for: source)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showMail) {
            if let jpeg = image?.jpegData(compressionQuality: 0.9) {
                MailView(
                    subject: defaultSubject,
                    recipients: defaultRecipients,
                    body: defaultBody,
                    attachments: [
                        MailAttachment(data: jpeg, mimeType: "image/jpeg", fileName: "shipment-photo.jpg")
                    ]
                )
            }
        }
        .alert("Mail not set up", isPresented: $mailUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device isn't configured to send email. Configure Mail or use a mailto: link.")
        }
        .alert("No photo source available", isPresented: $imageSourceUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device doesn't have a camera or photo library available.")
        }
    }

    private var addPhotoButtonLabel: String {
        if availableImageSources.count == 1, let source = availableImageSources.first {
            return source.primaryActionLabel
        }
        return "Add Photo"
    }

    private var addPhotoButtonSystemImage: String {
        if availableImageSources.count == 1, let source = availableImageSources.first {
            return source.systemImageName
        }
        return "plus"
    }

    private var availableImageSources: [ImageSourceOption] {
        var options: [ImageSourceOption] = []
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            options.append(.camera)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            options.append(.photoLibrary)
        }
        return options
    }

    private func handleAddPhotoTapped() {
        let sources = availableImageSources
        guard !sources.isEmpty else {
            imageSourceUnavailableAlert = true
            return
        }

        if sources.count == 1, let source = sources.first {
            presentImagePicker(for: source)
        } else {
            showSourceOptions = true
        }
    }

    private func presentImagePicker(for source: ImageSourceOption) {
        imagePickerSource = source.sourceType
        showImagePicker = true
    }
}

private enum ImageSourceOption: String, CaseIterable, Identifiable {
    case camera
    case photoLibrary

    var id: String { rawValue }

    var label: String {
        switch self {
        case .camera:
            return "Camera"
        case .photoLibrary:
            return "Photo Library"
        }
    }

    var primaryActionLabel: String {
        switch self {
        case .camera:
            return "Take Photo"
        case .photoLibrary:
            return "Choose Photo"
        }
    }

    var systemImageName: String {
        switch self {
        case .camera:
            return "camera.fill"
        case .photoLibrary:
            return "photo.fill"
        }
    }

    var sourceType: UIImagePickerController.SourceType {
        switch self {
        case .camera:
            return .camera
        case .photoLibrary:
            return .photoLibrary
        }
    }
}

#if swift(>=5.9)
#Preview {
    ContentView()
}
#else
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
