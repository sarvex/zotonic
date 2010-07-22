%% @author Marc Worrell <marc@worrell.nl>
%% @copyright 2010 Marc Worrell
%% @date 2010-07-20
%% @doc Simple contact form.

%% Copyright 2010 Marc Worrell
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%% 
%%     http://www.apache.org/licenses/LICENSE-2.0
%% 
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(mod_contact).
-author("Marc Worrell <marc@worrell.nl>").

-mod_title("Contact Form").
-mod_description("Simple contact form. Mails a contact form to the administrator user.").
-mod_prio(500).

-include_lib("zotonic.hrl").

%% interface functions
-export([
    init/1,
    event/2
]).


%% @doc Initialize the contact module.  Make sure that the page_contact is present.
init(Context) ->
    z_datamodel:manage(?MODULE, datamodel(), Context).


%% @doc Handle the contact form submit.
event({submit, {contact, Args}, TriggerId, _TargetId}, Context) ->
    Template = proplists:get_value(email_template, Args, "email_contact.tpl"),
    Email = proplists:get_value(to, Args, m_config:get_value(mod_config, email, Context)),
    To = case z_utils:is_empty(Email) of
            true -> z_email:get_admin_email(Context);
            false -> Email
         end,
    From = z_context:get_q_validated("mail", Context),
    Vars = [{email_from, From},
            {name, z_context:get_q("name", Context)},
            {message, z_context:get_q("message", Context)},
            {fields, z_context:get_q_all_noz(Context)}],
    z_email:send_render(To, Template, Vars, Context),
    z_render:wire([ {slide_up, [{target, TriggerId}]},
                    {slide_down, [{target,"contact-form-sent"}]}], 
                  Context).

%%====================================================================
%% support functions
%%====================================================================

datamodel() ->
    [
        {resources,
            [
                {page_contact,
                    text,
                    [{title, <<"Contact">>},
                     {summary, <<"Get in contact with us! Use the form give some feedback.">>},
                     {page_path, <<"/contact">>}
                    ]
                }
            ]
        }
    ].
