# Get key and secret values from Twitter API
# Start-Process https://developer.twitter.com/en/apps
$key = ''
$secret = ''
$bytes = [System.Text.Encoding]::UTF8.GetBytes($key + ':' + $secret)
$token = [System.Convert]::ToBase64String($bytes)


$authDetails = @{
    Uri = 'https://api.twitter.com/oauth2/token'
    Method = 'POST'
    Headers = @{
        Authorization = 'Basic ' + $token
        'Content-Type' = 'application/x-www-form-urlencoded;charset=UTF-8'
    }
    Body = 'grant_type=client_credentials'
}

$oauth = Invoke-RestMethod @authDetails

$spsutah = @{
    Uri = 'https://api.twitter.com/1.1/statuses/user_timeline.json?count=10&screen_name=spsutah'
    Headers = @{ Authorization = 'Bearer ' + $oauth.access_token }
}

$twitter = Invoke-RestMethod @spsutah
$twitter | select id,text
