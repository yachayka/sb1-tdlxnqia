import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { LogOut, GraduationCap } from 'lucide-react';

export default function Navbar() {
  const { user, signOut } = useAuth();
  const navigate = useNavigate();

  const handleSignOut = async () => {
    try {
      await signOut();
      navigate('/login');
    } catch (error) {
      console.error('Error signing out:', error);
    }
  };

  if (!user) return null;

  return (
    <nav className="bg-white shadow-lg">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          <Link to="/" className="flex items-center space-x-2">
            <GraduationCap className="h-8 w-8 text-indigo-600" />
            <span className="font-bold text-xl">ApplicantsDB</span>
          </Link>
          
          <div className="flex space-x-4">
            <Link to="/applicants" className="text-gray-700 hover:text-indigo-600 px-3 py-2">
              Applicants
            </Link>
            <Link to="/programs" className="text-gray-700 hover:text-indigo-600 px-3 py-2">
              Programs
            </Link>
            <Link to="/applications" className="text-gray-700 hover:text-indigo-600 px-3 py-2">
              Applications
            </Link>
            <button
              onClick={handleSignOut}
              className="flex items-center text-gray-700 hover:text-indigo-600 px-3 py-2"
            >
              <LogOut className="h-5 w-5 mr-1" />
              Sign Out
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
}