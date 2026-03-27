extends Node

signal request_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, token: int, user_data: Dictionary)

@export var max_simultaneous_request: int = 5

var _next_token := 0
var _request_queue := []
var _pending_requests_by_token := {}

func request(url: String, user_data: Dictionary={}) -> int:
	var token := _next_token
	_next_token = _next_token + 1
	
	if _pending_requests_by_token.size() == max_simultaneous_request:
		# queue request for later
		_request_queue.push_back([url,user_data,token])
	else:
		# handle request now
		_request(url, user_data, token)
	
	return token
	
# internal method for creating a new request
func _request(url: String, user_data: Dictionary, token: int) -> void:
	var new_request := HTTPRequest.new()
	add_child(new_request)
	new_request.request_completed.connect(_on_request_complete.bind(token, user_data))
	var res := new_request.request(url)
	if res == OK:
		_pending_requests_by_token[token] = new_request
	else:
		vr.log_error('failed to request url = "%s"' % url)
		new_request.request_completed.disconnect(_on_request_complete)
		remove_child(new_request)
	
func cancel_request(token: int) -> void:
	if _pending_requests_by_token.has(token):
		var request : HTTPRequest = _pending_requests_by_token[token]
		request.request_completed.disconnect(_on_request_complete)
		request.cancel_request()
		remove_child(request)
		_pending_requests_by_token.erase(token)
	
func cancel_all() -> void:
	for token in _pending_requests_by_token.keys():
		self.cancel_request(token)

func _on_request_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, token: int, user_data: Dictionary) -> void:
	# clean up request
	remove_child(_pending_requests_by_token[token])
	_pending_requests_by_token.erase(token)
	
	# initiate next queued request if there is one
	if ! _request_queue.is_empty():
		var request_args = _request_queue[0]
		_request_queue.pop_front()
		self.request(request_args[0],request_args[1])
		
	request_complete.emit(result, response_code, headers, body, token, user_data)
