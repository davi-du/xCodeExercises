//
//  AddEntryViewController.swift
//  MyDiaryUIKit
//
//  Created by Davide Cidu on 21/07/2026.
//

//
//  AddEntryViewController.swift
//  MyDiaryUIKit
//

import UIKit
import SwiftData
import PhotosUI

class AddEntryViewController: UIViewController {

    var onSave: (() -> Void)?

    private let titleField = UITextField()
    private let datePicker = UIDatePicker()
    private let moodSegmented = UISegmentedControl(items: ["😊", "😢", "😠", "🤩", "😐"])
    private let contentTextView = UITextView()

    private let tagsTableView = UITableView()
    private var allTags: [Tag] = []
    private var selectedTagIDs: Set<PersistentIdentifier> = []

    private let newTagField = UITextField()
    private let addTagButton = UIButton(type: .system)

    private let addPhotoButton = UIButton(type: .system)
    private let photosStackView = UIStackView()
    private var selectedImagesData: [Data] = []

    private var modelContext: ModelContext {
        UIApplication.sharedModelContainer.mainContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Nuova voce"
        view.backgroundColor = .systemGroupedBackground

        setupNavigationBar()
        setupLayout()
        fetchTags()
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Annulla",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Salva",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
    }

    // MARK: - Layout helpers

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    private func cardContainer(for content: UIView) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false

        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12)
        ])

        return card
    }

    private func section(title: String, content: UIView) -> UIView {
        let stack = UIStackView(arrangedSubviews: [sectionLabel(title), cardContainer(for: content)])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func styledTextField(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.borderStyle = .none
        field.font = .systemFont(ofSize: 16)
    }

    private func styledButton(_ button: UIButton, title: String, systemImage: String) {
        var config = UIButton.Configuration.tinted()
        config.title = title
        config.image = UIImage(systemName: systemImage)
        config.imagePadding = 6
        config.cornerStyle = .medium
        button.configuration = config
    }

    // MARK: - Setup

    private func setupLayout() {
        styledTextField(titleField, placeholder: "Titolo")

        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact

        moodSegmented.selectedSegmentIndex = 4 // .bored di default

        contentTextView.font = .systemFont(ofSize: 16)
        contentTextView.backgroundColor = .clear
        contentTextView.isScrollEnabled = false
        contentTextView.textContainerInset = .zero
        contentTextView.textContainer.lineFragmentPadding = 0

        // Tag
        tagsTableView.dataSource = self
        tagsTableView.delegate = self
        tagsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TagCell")
        tagsTableView.translatesAutoresizingMaskIntoConstraints = false
        tagsTableView.backgroundColor = .clear
        tagsTableView.separatorStyle = .none
        tagsTableView.isScrollEnabled = false
        tagsTableView.rowHeight = 40
        tagsTableView.heightAnchor.constraint(equalToConstant: 120).isActive = true

        styledTextField(newTagField, placeholder: "Nuovo tag")
        styledButton(addTagButton, title: "Aggiungi", systemImage: "plus")
        addTagButton.addTarget(self, action: #selector(addTagTapped), for: .touchUpInside)

        let tagInputStack = UIStackView(arrangedSubviews: [newTagField, addTagButton])
        tagInputStack.axis = .horizontal
        tagInputStack.spacing = 8
        tagInputStack.alignment = .center

        let tagsContentStack = UIStackView(arrangedSubviews: [tagsTableView, tagInputStack])
        tagsContentStack.axis = .vertical
        tagsContentStack.spacing = 10

        // Foto
        styledButton(addPhotoButton, title: "Aggiungi foto", systemImage: "photo.on.rectangle.angled")
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)

        photosStackView.axis = .horizontal
        photosStackView.spacing = 8
        photosStackView.translatesAutoresizingMaskIntoConstraints = false

        let photosScrollView = UIScrollView()
        photosScrollView.translatesAutoresizingMaskIntoConstraints = false
        photosScrollView.addSubview(photosStackView)
        photosScrollView.heightAnchor.constraint(equalToConstant: 84).isActive = true

        NSLayoutConstraint.activate([
            photosStackView.topAnchor.constraint(equalTo: photosScrollView.topAnchor),
            photosStackView.leadingAnchor.constraint(equalTo: photosScrollView.leadingAnchor),
            photosStackView.trailingAnchor.constraint(equalTo: photosScrollView.trailingAnchor),
            photosStackView.bottomAnchor.constraint(equalTo: photosScrollView.bottomAnchor),
            photosStackView.heightAnchor.constraint(equalTo: photosScrollView.heightAnchor)
        ])

        let photosContentStack = UIStackView(arrangedSubviews: [addPhotoButton, photosScrollView])
        photosContentStack.axis = .vertical
        photosContentStack.spacing = 10
        photosContentStack.alignment = .leading

        // Sezioni
        let detailsContent = UIStackView(arrangedSubviews: [titleField, divider(), datePicker])
        detailsContent.axis = .vertical
        detailsContent.spacing = 10

        let mainStack = UIStackView(arrangedSubviews: [
            section(title: "Dettagli", content: detailsContent),
            section(title: "Come ti senti?", content: moodSegmented),
            section(title: "Tag", content: tagsContentStack),
            section(title: "Foto", content: photosContentStack),
            section(title: "Racconta", content: contentTextView)
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            mainStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            mainStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    private func divider() -> UIView {
        let line = UIView()
        line.backgroundColor = .separator
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    private func fetchTags() {
        let descriptor = FetchDescriptor<Tag>(sortBy: [SortDescriptor(\.name)])
        allTags = (try? modelContext.fetch(descriptor)) ?? []
        tagsTableView.reloadData()
    }

    @objc private func addTagTapped() {
        guard let name = newTagField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let tag = Tag(name: name)
        modelContext.insert(tag)
        allTags.append(tag)
        selectedTagIDs.insert(tag.persistentModelID)
        newTagField.text = ""
        tagsTableView.reloadData()
    }

    @objc private func addPhotoTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func addThumbnail(for data: Data) {
        guard let uiImage = UIImage(data: data) else { return }

        let imageView = UIImageView(image: uiImage)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 76).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 76).isActive = true

        photosStackView.addArrangedSubview(imageView)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        guard let title = titleField.text, !title.isEmpty else { return }

        let mood = moodForSegmentIndex(moodSegmented.selectedSegmentIndex)

        let newEntry = DiaryEntry(
            title: title,
            date: datePicker.date,
            content: contentTextView.text,
            mood: mood
        )
        newEntry.tags = allTags.filter { selectedTagIDs.contains($0.persistentModelID) }

        for data in selectedImagesData {
            let attachment = Attachment(imageData: data)
            attachment.entry = newEntry
            newEntry.attachments.append(attachment)
            modelContext.insert(attachment)
        }

        modelContext.insert(newEntry)

        do {
            try modelContext.save()
        } catch {
            print("Errore nel salvataggio: \(error)")
        }

        onSave?()
        dismiss(animated: true)
    }

    private func moodForSegmentIndex(_ index: Int) -> Mood {
        switch index {
        case 0: return .happy
        case 1: return .sad
        case 2: return .angry
        case 3: return .excited
        default: return .bored
        }
    }
}

extension AddEntryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allTags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath)
        let tag = allTags[indexPath.row]
        cell.textLabel?.text = tag.name
        cell.backgroundColor = .clear
        cell.accessoryType = selectedTagIDs.contains(tag.persistentModelID) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tag = allTags[indexPath.row]

        if selectedTagIDs.contains(tag.persistentModelID) {
            selectedTagIDs.remove(tag.persistentModelID)
        } else {
            selectedTagIDs.insert(tag.persistentModelID)
        }

        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let tag = allTags[indexPath.row]
        selectedTagIDs.remove(tag.persistentModelID)
        modelContext.delete(tag)

        do {
            try modelContext.save()
        } catch {
            print("Errore nell'eliminazione del tag: \(error)")
        }

        allTags.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension AddEntryViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let uiImage = image as? UIImage,
                      let data = uiImage.jpegData(compressionQuality: 0.8) else { return }

                DispatchQueue.main.async {
                    self?.selectedImagesData.append(data)
                    self?.addThumbnail(for: data)
                }
            }
        }
    }
}
