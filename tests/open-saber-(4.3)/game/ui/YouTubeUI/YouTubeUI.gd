extends Panel
class_name YoutubeUI

signal song_selected(video_metadata)

# path to a Oculus Quest toolkit keyboard (search for searching youtube)
@export var keyboard: OQ_UI2DKeyboard

@onready var api := $YouTubeAPI
@onready var search_line_edit := $SearchLineEdit as LineEdit
@onready var search_button := $SearchButton as Button
@onready var results_list := $ResultsList as ItemList
@onready var select_song_button := $SelectSongButton as Button
@onready var thumbnail_request_pool := $ThumbnailRequestPool

var _video_idx_by_id := {}

var selected_video_metadata = null

func _ready() -> void:
	UI_AudioEngine.attach_children(self)
	# setup keybaord reference and text input signal handler
	keyboard.text_input_enter.connect(_on_keybaord_text_input_enter)

# override hide() method to handle case where UI is inside a OQ_UI2DCanvas
func _hide() -> void:
	var parent_canvas: Node = self
	while parent_canvas != null:
		if parent_canvas is OQ_UI2DCanvas:
			(parent_canvas as OQ_UI2DCanvas).hide()
			break
		parent_canvas = parent_canvas.get_parent()
	
	if parent_canvas == null:
		self.visible = false

# override show() method to handle case where UI is inside a OQ_UI2DCanvas
func _show() -> void:
	var parent_canvas: Node = self
	while parent_canvas != null:
		if parent_canvas is OQ_UI2DCanvas:
			(parent_canvas as OQ_UI2DCanvas).show()
			break
		parent_canvas = parent_canvas.get_parent()
		
	if parent_canvas == null:
		self.visible = true

func _on_SearchButton_pressed() -> void:
	select_song_button.disabled = true
	results_list.clear()
	_video_idx_by_id.clear()
	search_button.disabled = true
	thumbnail_request_pool.cancel_all()
	var search_text = search_line_edit.text
	api.search(search_text)

func _on_YouTubeAPI_failed_request() -> void:
	search_button.disabled = false
	vr.log_error('Search failed!')

func _on_YouTubeAPI_search_complete(videos) -> void:
	search_button.disabled = false
	
	for video in videos:
		var id = video['videoId']
		var metadata = {
			'id': id,
			'title': ""
		}
		for title_runs in video['title']['runs']:
			metadata['title'] = title_runs['text']
			break
		
		# add item to the list
		results_list.add_item(metadata['title'], null, true)
		
		# set metadata
		var idx = results_list.get_item_count() - 1
		_video_idx_by_id[id] = idx
		results_list.set_item_metadata(idx, metadata)
		results_list.set_item_icon(idx, $DefaultThumbnail.texture)
		results_list.set_item_tooltip_enabled(idx, false)
		
		# request thumbnail for video
		var thumbnail_url = null
		for thumbnail in video['thumbnail']['thumbnails']:
			# just take first one for now
			# TODO chose the smallest resolution of them all
			thumbnail_url = thumbnail['url']
			break
		if thumbnail_url != null:
			# pass video metadata as 'user_data' to request pool
			var token = thumbnail_request_pool.request(thumbnail_url, metadata)
			if token < 0:
				vr.log_error('failed to request thumbnail')

func _on_ThumbnailRequestPool_request_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, token: int, user_data: Dictionary) -> void:
	if response_code == HTTPClient.RESPONSE_OK:
		var img := ImageUtils.get_img_from_buffer(body)
		if img == null:
			vr.log_error('failed to parse valid image data for video %s' % user_data['id'])
			# leave default thumbnail
			return
		
		var img_tex := ImageTexture.new()
		img_tex.create_from_image(img)
		var size := img.get_size()
		size = size * 100.0 / img.get_height()# resize to max height of 100px
		img_tex.set_size_override(size)
		
		var item_idx = _video_idx_by_id[user_data['id']]
		results_list.set_item_icon(item_idx, img_tex)
	else:
		vr.log_error('received error code from thumbnail request' % response_code)


func _on_SelectSongButton_pressed() -> void:
	song_selected.emit(selected_video_metadata)
	self.hide()

func _on_BackButton_pressed() -> void:
	self.hide()

func _on_ResultsList_item_selected(index: int) -> void:
	selected_video_metadata = results_list.get_item_metadata(index)
	select_song_button.disabled = false

func _on_SearchLineEdit_focus_entered() -> void:
	keyboard._show()

func _on_keybaord_text_input_enter(text: String) -> void:
	# only handle text inputs while the UI is visible
	# Note: we could be sharing the keyboard with other dialogs too. Should
	# probably handle this a litte more ellegantly at some point...
	if visible:
		search_line_edit.text = text
