function send_email(emailto,subject,body,password,varargin)
% Send an email
% send_email('someone@mail.com','subject','body',<password>);
% send_email('someone@mail.com','subject','body',<password>,{'attachment.doc'});
 
if nargin>3
    attachments=varargin{1};
else
    attachments=[];
end
user = 'jorpez07@gmail.com';
mail = 'jorpez07@gmail.com';
psswd = password;
host = 'smtp.gmail.com';
port  = '465';
 
%emailto = 'jon-cama@gatech.edu';
m_subject = subject;% 'MATLAB SIMULATION';
m_text = body;%'Something is wrong with the simulation\t stopped at trial %d',trialNumber;
 
setpref( 'Internet','E_mail', mail );
setpref( 'Internet', 'SMTP_Server', host );
setpref( 'Internet', 'SMTP_Username', user );
setpref( 'Internet', 'SMTP_Password', psswd );
 
props = java.lang.System.getProperties;
props.setProperty( 'mail.smtp.user', mail );
props.setProperty( 'mail.smtp.host', host );
props.setProperty( 'mail.smtp.port', port );
props.setProperty( 'mail.smtp.starttls.enable', 'true' );
props.setProperty( 'mail.smtp.debug', 'true' );
props.setProperty( 'mail.smtp.auth', 'true' );
props.setProperty('mail.smtp.starttls.enable',     'true');  % Note: 'true' as a string, not a logical value!
props.setProperty( 'mail.smtp.socketFactory.port', port );
props.setProperty( 'mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory' );
props.setProperty( 'mail.smtp.socketFactory.fallback', 'false' );
 
if ~isempty(attachments)    
    sendmail( emailto , m_subject,m_text,attachments);
else
    sendmail( emailto , m_subject,m_text);
end
 
end