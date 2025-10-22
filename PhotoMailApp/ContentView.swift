import SwiftUI
import MessageUI

struct ContentView: View {
    @State private var image: UIImage?
    @State private var showCamera = false
    @State private var showMail = false
    @State private var mailUnavailableAlert = false

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
                        showCamera = true
                    } label: {
                        Label("Take Photo", systemImage: "camera.fill")
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
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { picked in
                image = picked
            }
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
