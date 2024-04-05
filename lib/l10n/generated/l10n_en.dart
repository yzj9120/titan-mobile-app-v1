// ignore_for_file: non_constant_identifier_names, use_super_parameters

import 'l10n.dart';

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get welcome_to_titan => 'Welcome to Titan';

  @override
  String get forget_password => '忘记密码';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email_verification_code => 'Email code';

  @override
  String get sender_decoder => 'Send code';

  @override
  String get sent => 'Sent';

  @override
  String get password => 'Password';

  @override
  String get set_password => 'Set a password';

  @override
  String get confirm_password => 'Confirm password';

  @override
  String get invitation_code => '邀请码（选填）';

  @override
  String get login_entry => '已有有帐号？点击登录';

  @override
  String get register_entry => '还没有帐号？点击注册';

  @override
  String get confirm_modification => '确认修改';

  @override
  String get privacy_policy_1 => '我已阅读并同意';

  @override
  String get privacy_policy_2 => '《Titan的使用协议》';

  @override
  String get privacy_policy => '隐私协议';

  @override
  String get verification_drag_tip => '请按住滑块，拖动到最右边';

  @override
  String get usage_protocol => '使用协议';

  @override
  String get privacy_content =>
      '在此特别提醒您（用户）在注册成为用户之前，请认真阅读本《用户注册及使用App隐私协议》（以下简称“协议”），确保您充分理解本协议中各条款。请您审慎阅读并选择接受或不接受本协议。除非您接受本协议所有条款，否则您无权注册、登录或使用本协议所涉服务。您的注册、登录、使用等行为将视为对本协议的接受，并同意接受本协议各项条款的约束。本协议约定律众云（北京）网络有限责任公司（以下简称“律师到了”）与用户之间关于律师到了软件服务（以下简称“服务”）的权利义务。用户，是指注册、登录、使用本服务的个人或组织。本协议可由律师到了随时更新，更新后的协议条款一旦公布即代替原来的协议条款，恕不再另行通知，用户可在本App中查阅最新版协议条款。在修改协议条款后，如果用户不接受修改后的条款，请立即停止使用律师到了提供的服务，用户继续使用律师到了提供的服务将被视为接受   一、账号注册   1、用户在使用本服务前需要注册一个律师到了App账号。律师到了App账号应当使用手机号码、或者律师到了绑定注册，请用户使用尚未与律师到了App账号绑定的手机号码，以及未被律师到了根据本协议封禁的手机号码注册律师到了App账号。律师到了可以根据用户需求或产品需要对账号注册和绑定的方式进行变更，而无须事先通知用户。     2、鉴于律师到了App账号的绑定注册方式，您同意律师到了在注册时将允许您的手机号码及手机设备识别码等信息用于注册。';

  @override
  String get today_earnings => 'Today\'s Rewards';

  @override
  String get ttn => 'TTN';

  @override
  String get email => 'Email Address';

  @override
  String get current_device_ID => 'Current Device ID';

  @override
  String get stop_earning_coins => 'Stop Earning';

  @override
  String get start_earning_coins => 'Start Earning';

  @override
  String get view_earnings_details => 'View reward details';

  @override
  String get initializing => 'Initializing';

  @override
  String get running => 'Running';

  @override
  String get to_update => '去更新';

  @override
  String get new_version => '发现新版本 ';

  @override
  String get tab_home => 'Home';

  @override
  String get tab_wallet => 'wallet';

  @override
  String get tab_history => 'History';

  @override
  String get tab_setting => 'Settings';

  @override
  String get setting_huygens_testnet => 'Huygens Testnet';

  @override
  String get about_titan => '关于Titan';

  @override
  String get login_account => '登录账号';

  @override
  String get wallet_address => 'Wallet Address';

  @override
  String get logout => '退出登录';

  @override
  String get setting_change_language => 'Languages';

  @override
  String get setting_language_zh => 'ZH';

  @override
  String get setting_language_en => 'EN';

  @override
  String get setting_twitter => 'Twitter';

  @override
  String get setting_discord => 'Discord';

  @override
  String get setting_telegram => 'Telegram';

  @override
  String get setting_about_titan => 'About Titan Network';

  @override
  String get setting_official_site => 'Official Site';

  @override
  String get setting_version => 'Version';

  @override
  String get setting_automatic_updates => 'Automatic Updates';

  @override
  String get setting_up_to_date => 'You are up to date';

  @override
  String get setting_update_now => 'Update Now';

  @override
  String setting_update_info_1(Object version) {
    return 'Dear User,\nThis update provides important bug fixes and security updates which include $version, and we recommend all users to update as soon as possible.';
  }

  @override
  String get setting_update_info_2 =>
      'For information on the security content of Titan Network software updates, please visit the following website:';

  @override
  String get history_title => 'Node Records';

  @override
  String get history_status => 'Status：';

  @override
  String get history_environment => 'Environment：';

  @override
  String get history_time => 'Time：';

  @override
  String get wallet_get_identity_title => '01.Request an Identity Code';

  @override
  String get wallet_get_identity_desc =>
      'Welcome to Titan Network! Please request an identity code for you device, and claim your rewards after binding the code.';

  @override
  String get wallet_get_identity_button => 'Request an Identity Code';

  @override
  String get wallet_input_identity_title => '02.Enter Your Identity Code';

  @override
  String get wallet_input_identity_desc =>
      'Please bind your identity code asap to avoid losing rewards.';

  @override
  String get wallet_input_identity_button => 'Bind Your Identity Code';

  @override
  String get wallet_verify_information => 'Verify Information';

  @override
  String get wallet_account => 'Account';

  @override
  String get wallet_email_address => 'Email Address';

  @override
  String get wallet_wallet_address => 'Wallet Address';

  @override
  String get wallet_confirm_bind => 'Confirm to bind';

  @override
  String get wallet_bound => 'Bound';

  @override
  String get wallet_user => 'User';

  @override
  String get wallet_device_management => 'Device Management';

  @override
  String get error_device_has_bound => 'Device Already Bound';

  @override
  String get error_signature => 'Invalid Signature';

  @override
  String get error_parameter => 'Invalid Parameters';

  @override
  String get error_unknown => 'Unknown Error';

  @override
  String get error_invalid_token => 'Invalid identity code';

  @override
  String get error_network => 'Network Error';

  @override
  String get error_token_has_bound => 'Identity code has been used';

  @override
  String get error_node_not_exists => 'The node is not logged in';

  @override
  String get failed_stop => 'Failed to Stop';

  @override
  String get failed_start => 'Startup failed';

  @override
  String get failed_bind => 'Bind failed';

  @override
  String get belongs => 'Titan Account related to identity code';

  @override
  String get bound => 'Bound';

  @override
  String get back => 'Back';
}
