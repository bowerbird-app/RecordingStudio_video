# frozen_string_literal: true

class VideosController < ApplicationController
  def index
    @roots = Workspace.order(:name).map { |workspace| RecordingStudio.root_recording_for(workspace) }
  end

  def new
    @video = RecordingStudioVideo::Video.new
    @workspace_id = parent_root.id
    @form_url = videos_path
    @form_method = :post
  end

  def create
    @workspace_id = parent_root.id
    @video = RecordingStudioVideo::Video.new(video_params)
    @form_url = videos_path
    @form_method = :post
    return render :new, status: :unprocessable_entity unless @video.valid?

    parent_root.record(RecordingStudioVideo::Video, parent_recording: parent_root) do |video|
      video.assign_attributes(video_params)
    end

    redirect_to videos_path
  end

  def edit
    @recording = video_recording
    @video = @recording.recordable
    @workspace_id = @recording.root_recording_id
    @form_url = video_path(@recording)
    @form_method = :patch
  end

  def update
    @recording = video_recording
    @video = @recording.recordable.dup
    @video.assign_attributes(video_params)
    @workspace_id = @recording.root_recording_id
    @form_url = video_path(@recording)
    @form_method = :patch
    return render :edit, status: :unprocessable_entity unless @video.valid?

    @recording.root_recording.revise(@recording) do |video|
      video.assign_attributes(video_params)
    end

    redirect_to videos_path
  end

  private

  def parent_root
    if params[:workspace_id].present?
      RecordingStudio::Recording.find(params[:workspace_id])
    else
      workspace = Workspace.find_by(name: "Studio Workspace") || Workspace.order(:created_at).first!
      RecordingStudio.root_recording_for(workspace)
    end
  end

  def video_recording
    recording = RecordingStudio::Recording.find(params[:id])
    raise ActiveRecord::RecordNotFound unless recording.recordable.is_a?(RecordingStudioVideo::Video)

    recording
  end

  def video_params
    params.require(:video).permit(:title, :url, :description)
  end
end
