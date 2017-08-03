//
//  DownloadManager.swift
//  Jisc
//
//  Created by Therapy Box on 10/19/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let LOG_ACTIVITY = true

//let hostPath = "http://therapy-box.com/jisc/"
let hostPath = "https://stuapp.analytics.alpha.jisc.ac.uk/"
let hostName = URL(string: hostPath)?.host

let getInstitutesPath = "fn_get_institutions"
let loginPath = "fn_login"
let staffLoginPath = "fn_staff_login"
let forgotPasswordPath = "fn_forgot_password"
let sendFriendRequestPath = "fn_send_friend_request"
let acceptFriendRequestPath = "fn_accept_friend_request"
let deleteFriendRequestPath = "fn_delete_friend_request"
let cancelFriendRequestPath = "fn_cancel_pending_friend_request"
let changeFriendSettingsPath = "fn_change_friend_settings"
let hideFriendPath = "fn_hide_friend"
let unhideFriendPath = "fn_unhide_friend"
let deleteFriendPath = "fn_delete_friend"
let getFriendsListPath = "fn_list_friends"
let getFriendRequestsPath = "fn_list_friend_requests"
let getStudentDetailsPath = "fn_view_student"
let getStudentsInTheSameCoursePath = "fn_get_students_in_same_course"
let getStudentByEmailPath = "fn_get_student_details_by_email"
let searchStudentByEmailPath = "fn_search_student_by_email"
let getStudentActivityLogsPath = "fn_get_activity_logs"
let getStudentModulesPath = "fn_get_student_modules"
let addActivityLogPath = "fn_add_activity_log"
let editActivityLogPath = "fn_edit_activity_log"
let viewActivityLogPath = "fn_view_activity_log"
let deleteActivityLogPath = "fn_delete_activity_log"
let getTargetsPath = "fn_get_targets"
let addTargetPath = "fn_add_target"
let editTargetPath = "fn_edit_target"
let viewTargetDetailsPath = "fn_view_target"
let deleteTargetPath = "fn_delete_target"
let checkTargetCompletionStatusPath = "fn_complete_target"
let getStretchTargetsPath = "fn_get_stretch_targets"
let addStretchTargetPath = "fn_add_stretch_target"
let editStretchTargetPath = "fn_edit_stretch_target"
let viewStretchTargetPath = "fn_view_stretch_target"
let deleteStretchTargetPath = "fn_delete_stretch_target"
let completeStretchTargetPath = "fn_complete_stretch_target"
let getTrophiesPath = "fn_get_trophies"
let getStudentTrophiesPath = "fn_get_student_trophies"
let getFeedsPath = "fn_get_feeds"
let postFeedMessagePath = "fn_post_message"
let deleteFeedPath = "fn_delete_feed"
let hideFeedPath = "fn_hide_feed"
let unhideFeedPath = "fn_unhide_feed"
let listSentFriendRequestsPath = "fn_list_sent_friend_requests"
let changeAppSettingsPath = "fn_change_app_settings"
let getAppSettingsPath = "fn_get_student_app_settings"
let editProfilePath = "fn_edit_profile_picture"
let getMarksObtainedByStudentPath = "fn_marks_obtained_by_student"
let getActivityPointsPath = "fn_get_activity_points"
let getCurrentWeekRankingPath = "fn_get_current_week_ranking"
let getOverallRankingPath = "fn_get_overall_ranking"
let getAssignmentRankingPath = "fn_get_assignment_ranking"
let getEngagementDataForTimePeriodPath = "fn_get_engagement_data_for_time_period"
let getEngagementDataForTimePeriodAndModulePath = "fn_get_engagement_data_for_time_period_and_module"
let getEngagementDataForTimePeriodAndCompareToPath = "fn_get_engagement_data_for_time_period_and_compareto"
let getEngagementDataForTimePeriodModuleAndCompareToPath = "fn_get_engagement_data_for_time_period_module_and_compareto"
let getConsentSettingsPath = "fn_get_consent_settings"
let setConsentSettingsPath = "fn_consent_settings"
let getPeopleOnStudentModulePath = "fn_get_people_on_student_module"
let sendFriendRequestByEmailPath = "fn_send_friend_request_by_email"
let getFriendsByModulePath = "fn_list_friends_by_module"
let socialLoginPath = "fn_social_login"
let addSocialModulePath = "fn_add_module"
let getSocialModulesPath = "fn_get_modules"
let registerForRemoteNotificationsPath = "fn_register_device"
let getPushNotificationsPath = "fn_get_push_notifications"
let changeReadStatusForNotificationPath = "fn_update_notifications_read_status"

enum kRequestStatusCode:Int {
	case `continue` = 100
	case switchingProtocols = 101
	case ok = 200
	case created = 201
	case accepted = 202
	case nonAuthoritativeInformation = 203
	case noContent = 204
	case resetContent = 205
	case partialContent = 206
	case multipleChoices = 300
	case movedPermanently = 301
	case found = 302
	case seeOther = 303
	case notModified = 304
	case useProxy = 305
	case unused = 306
	case temporaryRedirect = 307
	case badRequest = 400
	case unauthorized = 401
	case paymentRequired = 402
	case forbidden = 403
	case notFound = 404
	case methodNotAllowed = 405
	case notAcceptable = 406
	case proxyAuthenticationRequired = 407
	case requestTimeout = 408
	case conflict = 409
	case gone = 410
	case lengthRequired = 411
	case preconditionFailed = 412
	case requestEntityTooLarge = 413
	case requestURITooLong = 414
	case unsupportedMediaType = 415
	case requestedRangeNotSatisfiable = 416
	case expectationFailed = 417
	case internalServerError = 500
	case notImplemented = 501
	case badGateway = 502
	case serviceUnavailable = 503
	case gatewayTimeout = 504
	case httpVersionNotSupported = 505
}

enum kTimePeriod: String {
//	case Last24Hours = "last_24_hours"
	case Last7Days = "last_7_days"
	case Last30Days = "last_30_days"
	case Overall = "overall"
}

class FriendRequestPrivacyOptions {
	var shareMyResults:Bool
	var shareMyCourseEngagement:Bool
	var shareMyActivityLog:Bool
	
	init (results:Bool, engagement:Bool, activity:Bool) {
		shareMyResults = results
		shareMyCourseEngagement = engagement
		shareMyActivityLog = activity
	}
	
	func dictionary() -> [String:String] {
		var dictionary:[String:String] = [String:String]()
		if shareMyResults {
			dictionary["is_result"] = "yes"
		} else {
			dictionary["is_result"] = "no"
		}
		if shareMyCourseEngagement {
			dictionary["is_course_engagement"] = "yes"
		} else {
			dictionary["is_course_engagement"] = "no"
		}
		if shareMyActivityLog {
			dictionary["is_activity_log"] = "yes"
		} else {
			dictionary["is_activity_log"] = "no"
		}
		return dictionary
	}
}

var inheritSilent = false

typealias downloadCompletionBlock = ((_ success:Bool, _ result:NSDictionary?, _ results:NSArray?, _ error:String?) -> Void)

var internetAlertIsPresent = false

class DownloadManager: NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
	var rawData:NSMutableData = NSMutableData()
	var completionBlock:downloadCompletionBlock?
	var silent:Bool = inheritSilent
	var connectionSuccessfull:Bool = false
	var code:kRequestStatusCode?
	var shouldNotifyAboutInternetConnection:Bool = true
	
	//MARK: NSURLConnection Data Delegate
	func connection(_ connection: NSURLConnection, didReceive data: Data) {
		rawData.append(data)
	}
	
	func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
		let httpResponse = response as? HTTPURLResponse;
		if (httpResponse != nil) {
			code = kRequestStatusCode(rawValue:httpResponse!.statusCode)
			if (code != nil) {
				if (LOG_ACTIVITY && connection.originalRequest.url?.absoluteString != nil) {
					print("\(connection.originalRequest.url!.absoluteString) - code: \(code!)")
				}
				if (code == .ok || code == .noContent) {
					connectionSuccessfull = true
				}
				
				if (code == .unauthorized) {
					completionBlock = nil

					dataManager.logout()
					UIAlertView(title: localized("session_expired_title"), message: localized("session_expired_message"), delegate: nil, cancelButtonTitle: localized("ok")).show()
				}
			}
		}
	}
	
	func connectionDidFinishLoading(_ connection: NSURLConnection) {
		if (!silent) {
			LoadingView.hide()
		}
		if (completionBlock != nil) {
			do {
				let jsonObject = try JSONSerialization.jsonObject(with: rawData as Data, options: JSONSerialization.ReadingOptions.allowFragments)
				let dictionary:NSDictionary? = jsonObject as? NSDictionary
				if (dictionary != nil) {
					if (LOG_ACTIVITY) {
						DELEGATE.printDownloadResult(true, result: dictionary, results: nil, error: nil)
					}
					DispatchQueue.main.async(execute: { () -> Void in
						if (self.code == .noContent) {
							self.completionBlock!(true, nil, nil, nil)
						} else {
							self.completionBlock!(true, dictionary, nil, nil)
						}
					})
				} else {
					let array:NSArray? = jsonObject as? NSArray 
					if (array != nil) {
						if (LOG_ACTIVITY) {
							DELEGATE.printDownloadResult(true, result: nil, results: array, error: nil)
						}
						DispatchQueue.main.async(execute: { () -> Void in
							if (self.code == .noContent) {
								self.completionBlock!(true, nil, nil, nil)
							} else {
								self.completionBlock!(true, nil, array, nil)
							}
						})
					}
				}
			} catch {
				let string = String(data: rawData as Data, encoding: String.Encoding.utf8)
				
				if (string != nil) {
					if (connection.originalRequest.url?.absoluteString != nil) {
						if (code != nil) {
							print("\(connection.originalRequest.url!.absoluteString) - Received data to string: |\(string!)| (code: \(code!))")
						} else {
							print("\(connection.originalRequest.url!.absoluteString) - Received data to string: |\(string!)|")
						}
					}
					DispatchQueue.main.async(execute: { () -> Void in
						if (self.connectionSuccessfull) {
							if (LOG_ACTIVITY) {
								DELEGATE.printDownloadResult(true, result: ["message":string!], results: nil, error: nil)
							}
							if (self.code == .noContent) {
								self.completionBlock!(true, nil, nil, nil)
							} else {
								self.completionBlock!(true, ["message":string!], nil, string!)
							}
						} else {
							self.completionBlock!(false, nil, nil, string!)
							if (LOG_ACTIVITY) {
								DELEGATE.printDownloadResult(false, result: nil, results: nil, error: string!)
							}
						}
					})
				} else {
					print("Could not convert received data to string. Data length = \(rawData.length)")
					DispatchQueue.main.async(execute: { () -> Void in
						self.completionBlock!(false, nil, nil, "Unknown connection error.")
						if (LOG_ACTIVITY) {
							DELEGATE.printDownloadResult(false, result: nil, results: nil, error: "Unknown connection error.")
						}
					})
				}
			}
		}
	}
	
	//MARK: NSURLConnection Delegate
	
	func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
		if (!silent) {
			LoadingView.hide()
		}
		if (completionBlock != nil) {
			if (LOG_ACTIVITY) {
				DELEGATE.printDownloadResult(false, result: nil, results: nil, error: error.localizedDescription)
			}
			DispatchQueue.main.async(execute: { () -> Void in
				self.completionBlock!(false, nil, nil, error.localizedDescription)
			})
		}
	}
	
	//MARK: Helpful Functions
	
	func urlWithPath(_ path:String) -> URL? {
		let fullPath = "\(hostPath)\(path)"
		var theURL = URL(string: "")
		if let url = URL(string: fullPath) {
			theURL = url
		} else {
			print("URL failed: \(fullPath)")
		}
		return theURL
	}
	
	func bodyStringFromDictionary(_ dictionary:[String:String]) -> String {
		var string:String = ""
		let elements:NSMutableArray = NSMutableArray()
		let newDictionary:NSMutableDictionary = NSMutableDictionary(dictionary: dictionary)
		
		for key in newDictionary.allKeys
		{
			let argumentString:String? = key as? String
			let objectString:String? = newDictionary.object(forKey: key) as? String
			
			if (argumentString == nil) {
				print("key is nil")
				continue
			}
			
			if (objectString == nil) {
				print("object is nil")
				continue
			}
			
			elements.add("\(argumentString!)=\(objectString!)")
		}
		
		string = elements.componentsJoined(by: "&")
		
		let escapedString:String? = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
		
		if (escapedString != nil) {
			string = escapedString!
		}
		
		if (LOG_ACTIVITY) {
			print("body string:\n\(string)")
		}
		
		if (LOG_ACTIVITY) {
			let separator = "&"
			let array:[String] = string.components(separatedBy: separator)
			print("\(array)")
		}
		
		return string
	}
	
	func addAuthorizationHeader(_ request:NSMutableURLRequest?) {
		if let token = xAPIToken() {
//			request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
			request?.addValue("\(token)", forHTTPHeaderField: "Authorization")
		}
	}
	
	func createPostRequest(_ path:String, bodyString:String, withAuthorizationHeader:Bool)  -> NSMutableURLRequest? {
		let postData:Data? = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
		var request:NSMutableURLRequest?
		if let url = urlWithPath(path) {
			request = NSMutableURLRequest(url: url)
		}
		if (withAuthorizationHeader) {
			addAuthorizationHeader(request)
		}
		request?.httpMethod = "POST"
		if (postData != nil) {
			request?.setValue("\(postData!.count)", forHTTPHeaderField: "Content-Length")
			request?.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
		}
		request?.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
		return request
	}
	
	func createPutRequest(_ path:String, bodyString:String, withAuthorizationHeader:Bool)  -> NSMutableURLRequest? {
		let postData:Data? = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
		var request:NSMutableURLRequest?
		if let url = urlWithPath(path) {
			request = NSMutableURLRequest(url: url)
		}
		if (withAuthorizationHeader) {
			addAuthorizationHeader(request)
		}
		request?.httpMethod = "PUT"
		if (postData != nil) {
			request?.setValue("\(postData!.count)", forHTTPHeaderField: "Content-Length")
			request?.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
		}
		request?.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
		return request
	}
	
	func createDeleteRequest(_ path:String, withAuthorizationHeader:Bool)  -> NSMutableURLRequest? {
		var request:NSMutableURLRequest?
		if let url = urlWithPath(path) {
			request = NSMutableURLRequest(url: url)
		}
		if (withAuthorizationHeader) {
			addAuthorizationHeader(request)
		}
		request?.httpMethod = "DELETE"
		return request
	}
	
	func createGetRequest(_ path:String, withAuthorizationHeader:Bool) -> NSMutableURLRequest? {
		var request:NSMutableURLRequest?
		if let url = urlWithPath(path) {
			request = NSMutableURLRequest(url: url)
		}
		if (withAuthorizationHeader) {
			addAuthorizationHeader(request)
		}
		request?.httpMethod = "GET"
		return request
	}
	
	func createProfileImageUploadRequest(_ path: String, myID:String, image:UIImage, withAuthorizationHeader:Bool) -> NSMutableURLRequest?
	{
		var request:NSMutableURLRequest?
		if let url = urlWithPath(path) {
			request = NSMutableURLRequest(url: url)
		}
		if (withAuthorizationHeader) {
			addAuthorizationHeader(request)
		}
		request?.httpMethod = "POST"
		request?.timeoutInterval = 20.0
		
		let boundary = "---------------------------14737809831466499882746641449"
		
		let contentType = NSString(format: "multipart/form-data; boundary=%@", boundary)
		request?.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
		
		let body = NSMutableData()
		
		var data = (NSString(format: "\r\n--%@\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		data = (NSString(format: "Content-Disposition: form-data; name=\"student_id\"\r\n\r\n%@", myID)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		
		data = (NSString(format: "\r\n--%@\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		data = (NSString(format: "Content-Disposition: form-data; name=\"language\"\r\n\r\n%@", language)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		
		data = (NSString(format: "\r\n--%@\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		let fileName = "\(myID)_\(Date().timeIntervalSince1970)"

		let string = NSString(format: "Content-Disposition: attachment; name=\"image_data\"; filename=\"%@.png\"\r\nContent-Type: image/png\r\n\r\n", fileName)

		data = NSString(string: string).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		var newImage = image
		var imageData = UIImageJPEGRepresentation(newImage, 1.0)!
		while (imageData.count >= maximumImageSizeInBytes) {
			newImage = UIImage.scaleImage(newImage, toSize: CGSize(width: newImage.size.width * 0.9, height: newImage.size.height * 0.9))
			imageData = UIImageJPEGRepresentation(newImage, 1.0)!
		}
		print("image size: \(imageData.count)")
		body.append(imageData)
		
		data = (NSString(format: "\r\n--%@--\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		
		request?.httpBody = body as Data
		
		return request
	}
	
	func startConnectionWithRequest(_ request:NSURLRequest?) {
		if let request = request as? URLRequest {
			startConnectionWithURLRequest(request)
		} else {
			completionBlock?(false, nil, nil, "Error creating the url request")
		}
	}
	
	func startConnectionWithURLRequest(_ request:URLRequest) {
		if (internetAvailability == ReachabilityStatus.notInitialized) {
			let timer = Timer(timeInterval: 0.5, target: self, selector: #selector(DownloadManager.delayedConnection(_:)), userInfo: request, repeats: false)
			RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
		} else if (internetAvailability == ReachabilityStatus.notReachable) {
			if (shouldNotifyAboutInternetConnection && !internetAlertIsPresent) {
				internetAlertIsPresent = true
				UIAlertView(title: localized("connection_problem"), message: localized("check_internet"), delegate: DELEGATE, cancelButtonTitle: localized("ok")).show()
			}
			completionBlock?(false, nil, nil, nil)
		} else {
			if (!silent) {
				LoadingView.show()
			}
			let connection:NSURLConnection? = NSURLConnection(request: request, delegate: self, startImmediately: false)
			connection?.start()
			
			if (request.url?.absoluteString != nil && LOG_ACTIVITY) {
				let method:String? = request.httpMethod
				if (method != nil) {
					print(method!)
				}
				print("Request URL:\n\(request.url!.absoluteString)")
			}
		}
	}
	
	func delayedConnection(_ timer:Timer) {
		startConnectionWithRequest(timer.userInfo as? NSURLRequest)
	}
	
	//MARK: Download Functions
	
//	func getInstitutes(alertAboutInternet:Bool, completion:downloadCompletionBlock) {
//		shouldNotifyAboutInternetConnection = alertAboutInternet
//		completionBlock = completion
//		let request = createGetRequest("\(getInstitutesPath)?language=\(BundleLocalization.sharedInstance().language)", withAuthorizationHeader: false)
//		startConnectionWithRequest(request)
//	}
	
	func login(_ instituteID:String, email:String, password:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		dictionary["institution"] = instituteID
		dictionary["email"] = email
		dictionary["password"] = password
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		if currentUserType() == .social {
			dictionary["is_social"] = "yes"
		}
		startConnectionWithRequest(createPostRequest(loginPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: false))
	}
	
	func loginWithXAPI(_ jwt:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		if currentUserType() == .social {
			dictionary["is_social"] = "yes"
		}
		if currentUserType() == .staff {
			let request = createPostRequest(staffLoginPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true)
			startConnectionWithRequest(request)
		} else {
			let request = createPostRequest(loginPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true)
			startConnectionWithRequest(request)
		}
	}
	
	func socialLogin(email:String, name:String, userId:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		dictionary["email"] = email
		dictionary["full_name"] = name
		dictionary["social_id"] = userId
		dictionary["is_social"] = "yes"
		dictionary["institution"] = "1"
		startConnectionWithRequest(createPostRequest(socialLoginPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: false))
	}
	
	func forgotPassword(_ email:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		dictionary["email"] = email
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		if currentUserType() == .social {
			dictionary["is_social"] = "yes"
		}
		startConnectionWithRequest(createPostRequest(forgotPasswordPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
	}
	
	func sendFriendRequest(_ from:String, to:String, privacy:FriendRequestPrivacyOptions, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_send_friend_request"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = privacy.dictionary()
			dictionary["from_student_id"] = from
			dictionary["to_student_id"] = to
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPostRequest(sendFriendRequestPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func sendFriendRequestToEmail(_ from:String, email:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_send_friend_request"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = [String:String]()
			dictionary["from_student_id"] = from
			dictionary["to_email"] = email
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPostRequest(sendFriendRequestByEmailPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func acceptFriendRequest(_ from:String, to:String, privacy:FriendRequestPrivacyOptions, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_accept_request"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = privacy.dictionary()
			dictionary["from_user"] = from
			dictionary["student_id"] = to
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPutRequest(acceptFriendRequestPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func deleteFriendRequest(_ from:String, to:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_delete_request"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			var additionalParameters = "language=\(language)"
			if currentUserType() == .social {
				additionalParameters = "\(additionalParameters)&is_social=yes"
			}
			startConnectionWithRequest(createDeleteRequest("\(deleteFriendRequestPath)?deleted_user=\(from)&student_id=\(to)&\(additionalParameters)", withAuthorizationHeader: true))
		}
	}
	
	func cancelPendingFriendRequest(_ myID:String, friendID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_send_friend_request"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			var additionalParameters = "language=\(language)"
			if currentUserType() == .social {
				additionalParameters = "\(additionalParameters)&is_social=yes"
			}
			startConnectionWithRequest(createDeleteRequest("\(cancelFriendRequestPath)?student_id=\(myID)&friend_id=\(friendID)&\(additionalParameters)", withAuthorizationHeader: true))
		}
	}
	
	func changeFriendSettings(_ myID:String, friendID:String, privacy:FriendRequestPrivacyOptions, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_change_friend_settings"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = privacy.dictionary()
			dictionary["student_id"] = myID
			dictionary["friend_id"] = friendID
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPutRequest(changeFriendSettingsPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func hideFriend(_ myID:String, friendToHideID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(true, nil, nil, nil)
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = [String:String]()
			dictionary["from_student_id"] = myID
			dictionary["to_student_id"] = friendToHideID
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPutRequest(hideFriendPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func unhideFriend(_ myID:String, friendToUnhideID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(true, nil, nil, nil)
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = [String:String]()
			dictionary["from_student_id"] = myID
			dictionary["to_student_id"] = friendToUnhideID
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPutRequest(unhideFriendPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func deleteFriend(_ myID:String, friendToDeleteID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_delete_friend"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			var additionalParameters = "language=\(language)"
			if currentUserType() == .social {
				additionalParameters = "\(additionalParameters)&is_social=yes"
			}
			startConnectionWithRequest(createDeleteRequest("\(deleteFriendPath)?student_id=\(myID)&friend_id=\(friendToDeleteID)&\(additionalParameters)", withAuthorizationHeader: true))
		}
	}
	
	func getStudentsInTheSameCourse(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getStudentsInTheSameCoursePath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getStudentByEmail(_ myID:String, email:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getStudentByEmailPath)?student_id=\(myID)&email=\(email)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func searchStudentByEmail(_ myID:String, email:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(searchStudentByEmailPath)?student_id=\(myID)&email=\(email)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getFriendsList(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getFriendsListPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getFriendRequests(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getFriendRequestsPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getStudentDetails(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getStudentDetailsPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getStudentActivityLogs(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getStudentActivityLogsPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getStudentModules(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getStudentModulesPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func addActivityLog(_ log:ActivityLog, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_add_activity_log"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = log.dictionaryRepresentation()
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPostRequest(addActivityLogPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func editActivityLog(_ logID:String, activityDate:Date, timeSpentInMinutes:Int, note:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_edit_activity_log"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = [String:String]()
			dictionary["log_id"] = logID
			dictionary["student_id"] = dataManager.currentStudent!.id
			dateFormatter.dateFormat = "yyyy-MM-dd"
			dictionary["activity_date"] = dateFormatter.string(from: activityDate)
			dictionary["time_spent"] = "\(timeSpentInMinutes)"
			dictionary["note"] = note
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPutRequest(editActivityLogPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func viewActivityLog(_ logID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(viewActivityLogPath)?student_id=\(dataManager.currentStudent!.id)&log_id=\(logID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func deleteActivityLog(_ logID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_delete_activity_log"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			var additionalParameters = "language=\(language)"
			if currentUserType() == .social {
				additionalParameters = "\(additionalParameters)&is_social=yes"
			}
			startConnectionWithRequest(createDeleteRequest("\(deleteActivityLogPath)?student_id=\(dataManager.currentStudent!.id)&log_id=\(logID)&\(additionalParameters)", withAuthorizationHeader: true))
		}
	}
	
	func getTargets(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getTargetsPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func addTarget(_ myID:String, target:Target, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_add_target"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = target.dictionaryRepresentation()
			dictionary["student_id"] = myID
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPostRequest(addTargetPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func editTarget(_ target:Target, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_edit_target"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = [String:String]()
			dictionary["student_id"] = dataManager.currentStudent!.id
			dictionary["target_id"] = target.id
			dictionary["total_time"] = "\(target.totalTime)"
			dictionary["time_span"] = target.timeSpan
			if (target.module != nil) {
				dictionary["module"] = target.module!.id
			}
			if (!target.because.isEmpty) {
				dictionary["because"] = target.because
			}
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPutRequest(editTargetPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func viewTargetDetails(_ targetID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(viewTargetDetailsPath)?student_id=\(dataManager.currentStudent!.id)&target_id=\(targetID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func deleteTarget(_ targetID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_delete_target"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = ["target_id":targetID]
			dictionary["student_id"] = dataManager.currentStudent!.id
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPutRequest(deleteTargetPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func checkTargetCompletionStatus(_ targetID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = ["target_id":targetID]
		dictionary["student_id"] = dataManager.currentStudent!.id
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		if currentUserType() == .social {
			dictionary["is_social"] = "yes"
		}
		startConnectionWithRequest(createPutRequest(checkTargetCompletionStatusPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
	}
	
	func getStretchTargets(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getStretchTargetsPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func addStretchTarget(_ targetID:String, stretchTimeInMinutes:Int, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_add_target"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = [String:String]()
			dictionary["target_id"] = targetID
			dictionary["student_id"] = dataManager.currentStudent!.id
			dictionary["stretch_time"] = "\(stretchTimeInMinutes)"
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPostRequest(addStretchTargetPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func editStretchTarget(_ stretchTargetID:String, stretchTimeInMinutes:Int, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_edit_target"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = [String:String]()
			dictionary["stretch_target_id"] = stretchTargetID
			dictionary["student_id"] = dataManager.currentStudent!.id
			dictionary["stretch_time"] = "\(stretchTimeInMinutes)"
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPutRequest(editStretchTargetPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func viewStretchTarget(_ stretchTargetID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(viewStretchTargetPath)?student_id=\(dataManager.currentStudent!.id)&stretch_target_id=\(stretchTargetID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func deleteStretchTarget(_ stretchTargetID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_delete_target"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = [String:String]()
			dictionary["stretch_target_id"] = stretchTargetID
			dictionary["student_id"] = dataManager.currentStudent!.id
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPutRequest(deleteStretchTargetPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func completeStretchTarget(_ stretchTargetID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_add_target"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = [String:String]()
			dictionary["stretch_target_id"] = stretchTargetID
			dictionary["student_id"] = dataManager.currentStudent!.id
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPutRequest(completeStretchTargetPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func getTrophies(_ alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getTrophiesPath)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getStudentTrophies(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getStudentTrophiesPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getFeeds(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getFeedsPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func postFeedMessage(_ myID:String, message:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_post_message"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var dictionary = [String:String]()
			dictionary["student_id"] = myID
			dictionary["message"] = message
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			dictionary["language"] = language
			if currentUserType() == .social {
				dictionary["is_social"] = "yes"
			}
			startConnectionWithRequest(createPostRequest(postFeedMessagePath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
		}
	}
	
	func deleteFeed(_ feedID:String, myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		if currentUserType() == .demo {
			completion(false, nil, nil, localized("demo_mode_delete_feed"))
		} else {
			shouldNotifyAboutInternetConnection = alertAboutInternet
			completionBlock = completion
			var language = "en"
			if let newLanguage = BundleLocalization.sharedInstance().language {
				language = newLanguage
			}
			var additionalParameters = "language=\(language)"
			if currentUserType() == .social {
				additionalParameters = "\(additionalParameters)&is_social=yes"
			}
			startConnectionWithRequest(createDeleteRequest("\(deleteFeedPath)?feed_id=\(feedID)&student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
		}
	}
	
	func hideFeed(_ feedID:String, myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		dictionary["feed_id"] = feedID
		dictionary["student_id"] = myID
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		if currentUserType() == .social {
			dictionary["is_social"] = "yes"
		}
		startConnectionWithRequest(createPutRequest(hideFeedPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
	}
	
	func unhideFeed(_ feedID:String, myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		dictionary["feed_id"] = feedID
		dictionary["student_id"] = myID
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		if currentUserType() == .social {
			dictionary["is_social"] = "yes"
		}
		startConnectionWithRequest(createPutRequest(unhideFeedPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
	}
	
	func listSentFriendRequests(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(listSentFriendRequestsPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func changeAppSettings(_ myID:String, settingType:String, settingValue:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		dictionary["student_id"] = myID
		dictionary["setting_type"] = settingType
		dictionary["setting_value"] = settingValue
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		if currentUserType() == .social {
			dictionary["is_social"] = "yes"
		}
		startConnectionWithRequest(createPostRequest(changeAppSettingsPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
	}
	
	func getAppSettings(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getAppSettingsPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func editProfile(_ myID:String, image:UIImage?, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		if let image = image {
			completionBlock = completion
			startConnectionWithRequest(createProfileImageUploadRequest(editProfilePath, myID: myID, image: image, withAuthorizationHeader: true))
		} else {
			completion(true, nil, nil, nil)
		}
	}
	
	func getMarksObtainedByStudent(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getMarksObtainedByStudentPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getActivityPoints(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getActivityPointsPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getCurentWeekRanking(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getCurrentWeekRankingPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getOverallRanking(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getOverallRankingPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getAssignmentRanking(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getAssignmentRankingPath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getEngagementData(_ myID:String, timePeriod:kTimePeriod, moduleID:String?, compareToID:String?, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var path = "\(getEngagementDataForTimePeriodPath)?student_id=\(myID)&time_period=\(timePeriod.rawValue)"
		if (moduleID != nil && compareToID != nil) {
			path = "\(getEngagementDataForTimePeriodModuleAndCompareToPath)?student_id=\(myID)&time_period=\(timePeriod.rawValue)&module_id=\(moduleID!)&compare_to_id=\(compareToID!)"
		} else if (moduleID != nil) {
			path = "\(getEngagementDataForTimePeriodAndModulePath)?student_id=\(myID)&time_period=\(timePeriod.rawValue)&module_id=\(moduleID!)"
		} else if (compareToID != nil) {
			path = "\(getEngagementDataForTimePeriodAndCompareToPath)?student_id=\(myID)&time_period=\(timePeriod.rawValue)&compare_to_id=\(compareToID!)"
		}
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		path = "\(path)&\(additionalParameters)"
		startConnectionWithRequest(createGetRequest(path, withAuthorizationHeader: true))
	}
	
	func getConsentSettings(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		startConnectionWithRequest(createGetRequest("\(getConsentSettingsPath)?student_id=\(myID)", withAuthorizationHeader: true))
	}
	
	func setConsentSettings(_ myID:String, alertAboutInternet:Bool, analytics:Bool, privacy:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		dictionary["student_id"] = myID
		dictionary["is_consent"] = analytics ? "yes":"no"
		dictionary["is_privacy"] = privacy ? "yes":"no"
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		if currentUserType() == .social {
			dictionary["is_social"] = "yes"
		}
		startConnectionWithRequest(createPostRequest(setConsentSettingsPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
	}
	
	func getPeopleOnStudentModule(_ myID:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getPeopleOnStudentModulePath)?student_id=\(myID)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func getFriendsByModule(_ studentID:String, module:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getFriendsByModulePath)?student_id=\(studentID)&module=\(module)&\(additionalParameters)", withAuthorizationHeader: true))
	}
	
	func addSocialModule(studentId:String, module:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		dictionary["student_id"] = studentId
		dictionary["module"] = module
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		if currentUserType() == .social {
			dictionary["is_social"] = "yes"
		}
		startConnectionWithRequest(createPostRequest(addSocialModulePath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: false))
	}
	
	func getSocialModules(studentId:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		var additionalParameters = "language=\(language)"
		if currentUserType() == .social {
			additionalParameters = "\(additionalParameters)&is_social=yes"
		}
		startConnectionWithRequest(createGetRequest("\(getSocialModulesPath)?student_id=\(studentId)&\(additionalParameters)", withAuthorizationHeader: false))
	}
	
	func registerForRemoteNotifications(studentId:String, isActive:Int, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		dictionary["student_id"] = studentId
		dictionary["device_token"] = deviceId()
		if let bundleId = Bundle.main.bundleIdentifier {
			dictionary["bundle_identifier"] = bundleId
		} else {
			dictionary["bundle_identifier"] = "com.therapybox.studentapp"
		}
		dictionary["build"] = buildVersion()
		dictionary["version"] = appVersion()
		dictionary["is_active"] = "\(isActive)"
		dictionary["push_token"] = devicePushToken
		dictionary["platform"] = "ios"
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		if social() {
			dictionary["is_social"] = "yes"
		}
		startConnectionWithRequest(createPostRequest(registerForRemoteNotificationsPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
	}
	
	func getPushNotifications(studentdId:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		dictionary["student_id"] = studentdId
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		dictionary["language"] = language
		if social() {
			startConnectionWithRequest(createGetRequest("\(getPushNotificationsPath)?student_id=\(studentdId)&language=\(language)&is_social=yes", withAuthorizationHeader: true))
		} else {
			startConnectionWithRequest(createGetRequest("\(getPushNotificationsPath)?student_id=\(studentdId)&language=\(language)", withAuthorizationHeader: true))
		}
	}
	
	func markNotificationAsRead(studentdId:String, notificationId:String, alertAboutInternet:Bool, completion:@escaping downloadCompletionBlock) {
		shouldNotifyAboutInternetConnection = alertAboutInternet
		completionBlock = completion
		var dictionary = [String:String]()
		dictionary["student_id"] = studentdId
		dictionary["notification_id"] = notificationId
		dictionary["is_social"] = "yes"
		startConnectionWithRequest(createPutRequest(changeReadStatusForNotificationPath, bodyString: bodyStringFromDictionary(dictionary), withAuthorizationHeader: true))
	}
}
