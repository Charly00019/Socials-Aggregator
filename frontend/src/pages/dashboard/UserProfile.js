// UserProfile.js
export default function UserProfile({ user }) {
  return (
    <div className="user-profile">
      <h1>{user.displayName}</h1>
      <p className="user-handle">@{user.screenName || 'user'}</p>
      {user.email && <p className="user-email">{user.email}</p>}
    </div>
  );
}