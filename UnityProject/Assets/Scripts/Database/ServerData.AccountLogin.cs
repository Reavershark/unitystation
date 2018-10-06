﻿using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

namespace DatabaseAPI
{
	public partial class ServerData
	{
		public static void AttemptLogin(string username, string _password,
			Action<string> successCallBack, Action<string> failedCallBack)
		{
			var newRequest = new RequestLogin
			{
				username = username,
					password = _password,
					apiKey = ApiKey
			};

			Instance.StartCoroutine(Instance.PreformLogin(newRequest, successCallBack, failedCallBack));
		}

		IEnumerator PreformLogin(RequestLogin request,
			Action<string> successCallBack, Action<string> errorCallBack)
		{
			var requestData = JsonUtility.ToJson(request);
			UnityWebRequest r = UnityWebRequest.Get(URL_TryLogin + WWW.EscapeURL(requestData));
			yield return r.SendWebRequest();
			if (r.error != null)
			{
				Logger.Log("Login request failed: " + r.error, Category.DatabaseAPI);
				errorCallBack.Invoke(r.error);
			}
			else
			{
				var apiResponse = JsonUtility.FromJson<ApiResponse>(r.downloadHandler.text);
				if (apiResponse.errorCode != 0)
				{
					errorCallBack.Invoke(apiResponse.errorMsg);
					GameData.IsLoggedIn = false;
				}
				else
				{
					successCallBack.Invoke(apiResponse.message);
					string s = r.GetResponseHeader("set-cookie");
					sessionCookie = s.Split(';')[0];
					GameData.IsLoggedIn = true;
					GameData.LoggedInUsername = request.username;
				}
			}
		}
	}
}