namespace :verification_documents do
  # Remove verification documents whose file still lives on the decommissioned
  # S3 bucket (service_name = "amazon"). It deletes only the DB records
  # (ActiveStorage::Attachment + ActiveStorage::Blob) and never touches the
  # dead storage backend, so it is safe to run even while S3 is unreachable.
  #
  # Dry-run by default. To actually delete:
  #   DRY_RUN=false bin/rails verification_documents:purge_dead_s3
  desc "Remove verification documents still stored on the dead S3 bucket (DB-only)"
  task purge_dead_s3: :environment do
    dry_run = ENV["DRY_RUN"] != "false"
    dead_service = ENV.fetch("DEAD_SERVICE", "amazon")

    removed = 0
    ActiveStorage::Attachment.where(name: "verification_documents").find_each do |attachment|
      blob = attachment.blob
      next unless blob&.service_name == dead_service

      label = "attachment ##{attachment.id} blob ##{blob.id} (#{blob.filename})"
      if dry_run
        puts "[DRY RUN] would remove #{label}"
      else
        attachment.destroy
        blob.destroy
        puts "Removed #{label}"
      end
      removed += 1
    end

    if dry_run
      puts "\n[DRY RUN] #{removed} record(s) would be removed. Re-run with DRY_RUN=false to apply."
    else
      puts "\nRemoved #{removed} dead-S3 verification document record(s)."
    end
  end
end
